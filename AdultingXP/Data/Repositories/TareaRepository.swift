struct TareaRepository: TareaRepositoryProtocol {
    private let filename = "tareas.json"

    func cargar() -> [Tarea] {
        JSONStore.load([Tarea].self, fromFile: filename) ?? []
    }

    func guardar(_ tareas: [Tarea]) {
        JSONStore.save(tareas, toFile: filename)
    }
}
