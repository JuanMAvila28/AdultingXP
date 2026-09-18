import Foundation

struct RegistroTiempoPantalla: Identifiable, Codable {
    let id: UUID
    var semana: Date         // lunes de la semana a la que pertenece el registro
    var minutosUsados: Int
    var minutosLimite: Int
    var puntosOtorgados: Int // exactamente lo que se sumó/restó al ledger (puede ser negativo)

    init(
        id: UUID = UUID(),
        semana: Date,
        minutosUsados: Int,
        minutosLimite: Int,
        puntosOtorgados: Int
    ) {
        self.id = id
        self.semana = semana
        self.minutosUsados = minutosUsados
        self.minutosLimite = minutosLimite
        self.puntosOtorgados = puntosOtorgados
    }

    var cumplioLimite: Bool { minutosUsados <= minutosLimite }
    var exceso: Int { max(0, minutosUsados - minutosLimite) }

    var etiquetaSemana: String {
        let cal = Calendar.current
        if cal.isDate(semana, equalTo: inicioSemanaActual(), toGranularity: .weekOfYear) {
            return "Esta semana"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_CO")
        formatter.dateFormat = "d MMM"
        let fin = cal.date(byAdding: .day, value: 6, to: semana) ?? semana
        return "\(formatter.string(from: semana)) – \(formatter.string(from: fin))"
    }

    private func inicioSemanaActual() -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let c = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)
        return cal.date(from: c) ?? .now
    }
}
