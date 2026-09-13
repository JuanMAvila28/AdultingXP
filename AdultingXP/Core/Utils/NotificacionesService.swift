import UserNotifications

final class NotificacionesService {
    static let shared = NotificacionesService()
    private let center = UNUserNotificationCenter.current()
    private let idRecordatorio = "habitos.recordatorio.diario"

    private init() {}

    func solicitarPermiso() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func programarRecordatorio(hora: Int, minuto: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [idRecordatorio])

        let content = UNMutableNotificationContent()
        content.title = "Hábitos del día"
        content.body = "¿Ya registraste tus hábitos de hoy?"
        content.sound = .default

        var componentes = DateComponents()
        componentes.hour   = hora
        componentes.minute = minuto

        let trigger = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: true)
        let request = UNNotificationRequest(
            identifier: idRecordatorio,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelarRecordatorio() {
        center.removePendingNotificationRequests(withIdentifiers: [idRecordatorio])
    }

    // MARK: — Tareas

    private func idTarea(_ tarea: Tarea) -> String { "tarea.\(tarea.id.uuidString)" }

    func programarTarea(_ tarea: Tarea) {
        cancelarTarea(tarea)
        guard !tarea.completada, tarea.fechaLimite > .now else { return }

        // Aviso 24 h antes; si queda menos de 24 h avisa en 1 min para no perderse la ventana
        let anticipacion: TimeInterval = 24 * 3_600
        let fechaAviso = max(.now.addingTimeInterval(60),
                             tarea.fechaLimite.addingTimeInterval(-anticipacion))
        guard fechaAviso < tarea.fechaLimite else { return }

        let content = UNMutableNotificationContent()
        content.title = "Tarea por vencer"
        content.body  = "\"\(tarea.titulo)\" · \(tarea.materia)"
        content.sound = .default

        let componentes = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fechaAviso
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: false)
        center.add(UNNotificationRequest(
            identifier: idTarea(tarea),
            content: content,
            trigger: trigger
        ))
    }

    func cancelarTarea(_ tarea: Tarea) {
        center.removePendingNotificationRequests(withIdentifiers: [idTarea(tarea)])
    }
}
