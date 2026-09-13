import Foundation
import Observation

@Observable
final class TareasViewModel {
    private let tareaRepo: any TareaRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

    var tareas: [Tarea] = []
    var registros: [RegistroPuntos] = []

    var balanceGlobal: Int {
        registros.reduce(0) { $0 + $1.cantidad }
    }

    var tareasPendientes: [Tarea] {
        tareas.filter { !$0.completada }.sorted { $0.fechaLimite < $1.fechaLimite }
    }

    var tareasCompletadas: [Tarea] {
        tareas
            .filter { $0.completada }
            .sorted { ($0.fechaCompletada ?? .distantPast) > ($1.fechaCompletada ?? .distantPast) }
    }

    init(
        tareaRepo: any TareaRepositoryProtocol = TareaRepository(),
        registroRepo: any RegistroPuntosRepositoryProtocol = RegistroPuntosRepository()
    ) {
        self.tareaRepo = tareaRepo
        self.registroRepo = registroRepo
        tareas = tareaRepo.cargar()
        registros = registroRepo.cargar()
    }

    // MARK: — Acciones

    func agregar(_ tarea: Tarea) {
        tareas.append(tarea)
        tareaRepo.guardar(tareas)
    }

    func eliminar(_ tarea: Tarea) {
        tareas.removeAll { $0.id == tarea.id }
        tareaRepo.guardar(tareas)
    }
}
