import Foundation
import Observation

@Observable
final class TareasViewModel {
    private let tareaRepo: any TareaRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol
    private let completarUseCase: CompletarTareaUseCase

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
        self.completarUseCase = CompletarTareaUseCase(tareaRepo: tareaRepo, registroRepo: registroRepo)
        tareas = tareaRepo.cargar()
        registros = registroRepo.cargar()
    }

    // MARK: — Acciones

    func recargarRegistros() {
        registros = registroRepo.cargar()
    }

    func agregar(_ tarea: Tarea) {
        tareas.append(tarea)
        tareaRepo.guardar(tareas)
    }

    func eliminar(_ tarea: Tarea) {
        tareas.removeAll { $0.id == tarea.id }
        tareaRepo.guardar(tareas)
    }

    func completar(_ tarea: Tarea) {
        let resultado = completarUseCase.ejecutar(
            tarea: tarea,
            todasLasTareas: tareas,
            registrosActuales: registros
        )
        if let i = tareas.firstIndex(where: { $0.id == resultado.tareaActualizada.id }) {
            tareas[i] = resultado.tareaActualizada
        }
        registros.append(resultado.nuevoRegistro)
    }
}
