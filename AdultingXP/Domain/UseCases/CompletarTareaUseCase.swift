import Foundation

struct CompletarTareaUseCase {
    private let tareaRepo: any TareaRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

    init(
        tareaRepo: any TareaRepositoryProtocol,
        registroRepo: any RegistroPuntosRepositoryProtocol
    ) {
        self.tareaRepo = tareaRepo
        self.registroRepo = registroRepo
    }

    struct Resultado {
        let tareaActualizada: Tarea
        let nuevoRegistro: RegistroPuntos
    }

    func ejecutar(
        tarea: Tarea,
        todasLasTareas: [Tarea],
        registrosActuales: [RegistroPuntos]
    ) -> Resultado {
        let ahora = Date.now
        let aTiempo = ahora <= tarea.fechaLimite

        var actualizada = tarea
        actualizada.completada = true
        actualizada.fechaCompletada = ahora

        var tareasActualizadas = todasLasTareas
        if let i = tareasActualizadas.firstIndex(where: { $0.id == tarea.id }) {
            tareasActualizadas[i] = actualizada
        }
        tareaRepo.guardar(tareasActualizadas)

        let delta = aTiempo ? tarea.puntajeBase : -tarea.puntajeBase
        let concepto = aTiempo
            ? "✅ \(tarea.titulo)"
            : "⏰ \(tarea.titulo) (tarde)"
        let registro = RegistroPuntos(cantidad: delta, concepto: concepto, origen: .tarea)
        registroRepo.guardar(registrosActuales + [registro])

        return Resultado(tareaActualizada: actualizada, nuevoRegistro: registro)
    }
}
