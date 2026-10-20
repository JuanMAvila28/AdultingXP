import Foundation

struct TiempoTranscurridoFormatter {
    var ahora: () -> Date = { .now }

    func formatear(_ fecha: Date) -> String {
        let segundos = Int(ahora().timeIntervalSince(fecha))
        guard segundos >= 0 else { return "ahora" }

        switch segundos {
        case 0..<60:
            return "ahora"
        case 60..<3_600:
            let min = segundos / 60
            return "hace \(min) min"
        case 3_600..<86_400:
            let h = segundos / 3_600
            return h == 1 ? "hace 1 h" : "hace \(h) h"
        case 86_400..<604_800:
            let dias = segundos / 86_400
            return dias == 1 ? "hace 1 día" : "hace \(dias) días"
        case 604_800..<2_592_000:
            let sem = segundos / 604_800
            return sem == 1 ? "hace 1 sem" : "hace \(sem) sem"
        default:
            let meses = segundos / 2_592_000
            return meses == 1 ? "hace 1 mes" : "hace \(meses) meses"
        }
    }
}
