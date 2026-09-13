import Foundation

extension Date {
    var etiquetaDia: String {
        let cal = Calendar.current
        if cal.isDateInToday(self)     { return "Hoy" }
        if cal.isDateInYesterday(self) { return "Ayer" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_CO")
        let ahora = Date.now
        formatter.dateFormat = cal.isDate(self, equalTo: ahora, toGranularity: .year)
            ? "EEEE, d MMM"
            : "EEEE, d MMM yyyy"
        return formatter.string(from: self).capitalized
    }
}
