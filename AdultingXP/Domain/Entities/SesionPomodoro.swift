import Foundation

enum EstadoSesion: String, Codable {
    case enProgreso
    case pausado
    case completada
    case interrumpida
}

enum TipoSesionPomodoro: String, Codable {
    case trabajo
    case descansoCorto
    case descansoLargo

    var label: String {
        switch self {
        case .trabajo:       return "Trabajo"
        case .descansoCorto: return "Descanso corto"
        case .descansoLargo: return "Descanso largo"
        }
    }

    var esTrabajo: Bool { self == .trabajo }
}

struct SesionPomodoro: Identifiable, Codable {
    let id: UUID
    var fechaInicio: Date
    var duracionMinutos: Int
    var tipo: TipoSesionPomodoro
    var estado: EstadoSesion
    var segundosPausadoAcumulados: Int
    var fechaInicioUltimaPausa: Date?
    var fechaInterrupcion: Date?

    init(
        id: UUID = UUID(),
        fechaInicio: Date = .now,
        duracionMinutos: Int,
        tipo: TipoSesionPomodoro,
        estado: EstadoSesion = .enProgreso,
        segundosPausadoAcumulados: Int = 0,
        fechaInicioUltimaPausa: Date? = nil,
        fechaInterrupcion: Date? = nil
    ) {
        self.id = id
        self.fechaInicio = fechaInicio
        self.duracionMinutos = duracionMinutos
        self.tipo = tipo
        self.estado = estado
        self.segundosPausadoAcumulados = segundosPausadoAcumulados
        self.fechaInicioUltimaPausa = fechaInicioUltimaPausa
        self.fechaInterrupcion = fechaInterrupcion
    }

    /// Segundos restantes calculados desde fechaInicio, no desde un contador.
    /// Resiliente a backgrounding: funciona correctamente aunque la app estuviera suspendida.
    func segundosRestantes(ahora: Date = .now) -> Int {
        let duracionTotal = duracionMinutos * 60
        let pausadoActual: Int = {
            guard estado == .pausado, let inicio = fechaInicioUltimaPausa else { return 0 }
            return Int(ahora.timeIntervalSince(inicio))
        }()
        let transcurrido = Int(ahora.timeIntervalSince(fechaInicio))
                         - segundosPausadoAcumulados
                         - pausadoActual
        return max(0, duracionTotal - transcurrido)
    }

    func progreso(ahora: Date = .now) -> Double {
        let total = Double(duracionMinutos * 60)
        guard total > 0 else { return 0 }
        return min(1, max(0, 1 - Double(segundosRestantes(ahora: ahora)) / total))
    }

    /// Fecha en que debería terminar la sesión, considerando pausas acumuladas.
    func fechaFinEsperada(ahora: Date = .now) -> Date {
        ahora.addingTimeInterval(TimeInterval(segundosRestantes(ahora: ahora)))
    }
}
