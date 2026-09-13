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
}
