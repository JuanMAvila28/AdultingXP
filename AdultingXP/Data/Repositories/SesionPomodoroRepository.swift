import Foundation

struct SesionPomodoroRepository: SesionPomodoroRepositoryProtocol {
    private let filename = "sesiones_pomodoro.json"

    func cargar() -> [SesionPomodoro] {
        JSONStore.load([SesionPomodoro].self, fromFile: filename) ?? []
    }

    func guardar(_ sesiones: [SesionPomodoro]) {
        JSONStore.save(sesiones, toFile: filename)
    }
}
