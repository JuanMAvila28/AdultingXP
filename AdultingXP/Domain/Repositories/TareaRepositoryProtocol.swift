protocol TareaRepositoryProtocol {
    func cargar() -> [Tarea]
    func guardar(_ tareas: [Tarea])
}
