import Foundation

protocol SesionPomodoroRepositoryProtocol {
    func cargar() -> [SesionPomodoro]
    func guardar(_ sesiones: [SesionPomodoro])
}
