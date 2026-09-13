import Foundation

extension Double {
    /// Formatea como moneda local sin decimales: "$1.500.000"
    var moneda: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let numero = formatter.string(from: NSNumber(value: self)) ?? String(Int(self))
        return "$\(numero)"
    }
}
