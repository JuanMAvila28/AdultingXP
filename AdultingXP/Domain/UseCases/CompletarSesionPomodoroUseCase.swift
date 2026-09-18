import Foundation

struct CompletarSesionPomodoroUseCase {
    private let sesionRepo: any SesionPomodoroRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

    init(
        sesionRepo: any SesionPomodoroRepositoryProtocol = SesionPomodoroRepository(),
        registroRepo: any RegistroPuntosRepositoryProtocol = RegistroPuntosRepository()
    ) {
        self.sesionRepo = sesionRepo
        self.registroRepo = registroRepo
    }

    struct Resultado {
        let sesionActualizada: SesionPomodoro
        let nuevoRegistro: RegistroPuntos?  // nil si no era sesión de trabajo
    }

    func ejecutar(
        sesion: SesionPomodoro,
        todasLasSesiones: [SesionPomodoro],
        registrosActuales: [RegistroPuntos],
        puntosPorSesion: Int
    ) -> Resultado {
        var actualizada = sesion
        actualizada.estado = .completada

        var sesiones = todasLasSesiones
        if let i = sesiones.firstIndex(where: { $0.id == sesion.id }) {
            sesiones[i] = actualizada
        }
        sesionRepo.guardar(sesiones)

        guard sesion.tipo.esTrabajo else {
            return Resultado(sesionActualizada: actualizada, nuevoRegistro: nil)
        }

        let registro = RegistroPuntos(
            cantidad: puntosPorSesion,
            concepto: "🍅 Pomodoro completado",
            origen: .pomodoro
        )
        registroRepo.guardar(registrosActuales + [registro])
        return Resultado(sesionActualizada: actualizada, nuevoRegistro: registro)
    }
}
