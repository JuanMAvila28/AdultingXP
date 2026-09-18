import Foundation
import Observation

@Observable
final class PomodoroViewModel {
    private let sesionRepo: any SesionPomodoroRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol
    private let completarUseCase: CompletarSesionPomodoroUseCase
    private let notificaciones = NotificacionesService.shared

    var sesiones: [SesionPomodoro] = []
    var registros: [RegistroPuntos] = []
    var sesionActual: SesionPomodoro? = nil
    var segundosRestantes: Int = 0

    private var timer: Timer?

    // MARK: — Configuración (leída de UserDefaults)

    private func intSetting(_ key: String, default def: Int) -> Int {
        let v = UserDefaults.standard.integer(forKey: key)
        return v > 0 ? v : def
    }

    var duracionTrabajo:  Int { intSetting(UserSettings.Keys.pomodoroTrabajo,  default: 25) }
    var duracionCorto:    Int { intSetting(UserSettings.Keys.pomodoroCorto,     default: 5)  }
    var duracionLargo:    Int { intSetting(UserSettings.Keys.pomodoroLargo,     default: 15) }
    var sesionesParaLargo: Int { intSetting(UserSettings.Keys.pomodoroSesiones, default: 4)  }
    var puntosPorSesion:  Int { intSetting(UserSettings.Keys.pomodoroPuntos,   default: 10) }

    var balanceGlobal: Int { registros.reduce(0) { $0 + $1.cantidad } }

    // MARK: — Estado derivado

    var sesionesTrabajoHoy: Int {
        let cal = Calendar.current
        return sesiones.filter {
            $0.tipo.esTrabajo && $0.estado == .completada && cal.isDateInToday($0.fechaInicio)
        }.count
    }

    var siguienteTipo: TipoSesionPomodoro {
        guard let sesion = sesionActual, sesion.estado == .completada else { return .trabajo }
        switch sesion.tipo {
        case .trabajo:
            return sesionesTrabajoHoy % sesionesParaLargo == 0 ? .descansoLargo : .descansoCorto
        case .descansoCorto, .descansoLargo:
            return .trabajo
        }
    }

    var progreso: Double { sesionActual?.progreso() ?? 0 }

    func colorSesion(para tipo: TipoSesionPomodoro) -> String {
        switch tipo {
        case .trabajo:       return "#5E4ADB"
        case .descansoCorto: return "#059669"
        case .descansoLargo: return "#2563EB"
        }
    }

    // MARK: — Init

    init(
        sesionRepo: any SesionPomodoroRepositoryProtocol = SesionPomodoroRepository(),
        registroRepo: any RegistroPuntosRepositoryProtocol = RegistroPuntosRepository()
    ) {
        self.sesionRepo = sesionRepo
        self.registroRepo = registroRepo
        self.completarUseCase = CompletarSesionPomodoroUseCase(
            sesionRepo: sesionRepo,
            registroRepo: registroRepo
        )
        sesiones = sesionRepo.cargar()
        registros = registroRepo.cargar()

        // Restaurar sesión activa si la app se reinició
        if let activa = sesiones.first(where: { $0.estado == .enProgreso || $0.estado == .pausado }) {
            sesionActual = activa
            segundosRestantes = activa.segundosRestantes()
            if activa.estado == .enProgreso {
                // Podría haber terminado mientras la app estaba cerrada
                if segundosRestantes == 0 {
                    completarSesionActual()
                } else {
                    iniciarTimer()
                }
            }
        }
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: — Acciones públicas

    func iniciar(tipo: TipoSesionPomodoro) {
        let duracion: Int
        switch tipo {
        case .trabajo:       duracion = duracionTrabajo
        case .descansoCorto: duracion = duracionCorto
        case .descansoLargo: duracion = duracionLargo
        }

        let nueva = SesionPomodoro(duracionMinutos: duracion, tipo: tipo)
        sesiones.append(nueva)
        sesionRepo.guardar(sesiones)
        sesionActual = nueva
        segundosRestantes = duracion * 60

        notificaciones.programarPomodoro(
            finEn: nueva.fechaFinEsperada(),
            tipo: tipo
        )
        iniciarTimer()
    }

    func iniciarSiguiente() {
        sesionActual = nil
        iniciar(tipo: siguienteTipo)
    }

    func pausar() {
        guard var sesion = sesionActual, sesion.estado == .enProgreso else { return }
        timer?.invalidate(); timer = nil
        notificaciones.cancelarPomodoro()

        sesion.estado = .pausado
        sesion.fechaInicioUltimaPausa = .now
        guardarSesion(sesion)
    }

    func reanudar() {
        guard var sesion = sesionActual, sesion.estado == .pausado else { return }

        if let inicioPausa = sesion.fechaInicioUltimaPausa {
            sesion.segundosPausadoAcumulados += Int(Date.now.timeIntervalSince(inicioPausa))
        }
        sesion.fechaInicioUltimaPausa = nil
        sesion.estado = .enProgreso
        guardarSesion(sesion)

        segundosRestantes = sesion.segundosRestantes()
        notificaciones.programarPomodoro(finEn: sesion.fechaFinEsperada(), tipo: sesion.tipo)
        iniciarTimer()
    }

    func cancelar() {
        guard var sesion = sesionActual else { return }
        timer?.invalidate(); timer = nil
        notificaciones.cancelarPomodoro()

        sesion.estado = .interrumpida
        sesion.fechaInterrupcion = .now
        guardarSesion(sesion)
        sesionActual = nil
        segundosRestantes = 0
    }

    func recargar() {
        registros = registroRepo.cargar()
    }

    // MARK: — Privado

    private func iniciarTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.actualizarSegundos()
        }
    }

    private func actualizarSegundos() {
        guard let sesion = sesionActual, sesion.estado == .enProgreso else { return }
        let restantes = sesion.segundosRestantes()
        segundosRestantes = restantes
        if restantes == 0 {
            completarSesionActual()
        }
    }

    private func completarSesionActual() {
        guard let sesion = sesionActual else { return }
        timer?.invalidate(); timer = nil
        notificaciones.cancelarPomodoro()

        let resultado = completarUseCase.ejecutar(
            sesion: sesion,
            todasLasSesiones: sesiones,
            registrosActuales: registros,
            puntosPorSesion: puntosPorSesion
        )

        if let i = sesiones.firstIndex(where: { $0.id == resultado.sesionActualizada.id }) {
            sesiones[i] = resultado.sesionActualizada
        }
        if let nuevo = resultado.nuevoRegistro {
            registros.append(nuevo)
        }
        sesionActual = resultado.sesionActualizada
        segundosRestantes = 0
    }

    private func guardarSesion(_ sesion: SesionPomodoro) {
        if let i = sesiones.firstIndex(where: { $0.id == sesion.id }) {
            sesiones[i] = sesion
        }
        sesionRepo.guardar(sesiones)
        sesionActual = sesion
    }
}
