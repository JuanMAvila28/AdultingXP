import SwiftUI

extension Color {

    // MARK: — Marca
    /// Color de acento de la app (indigo cálido). Se adapta a light/dark vía Assets.
    static let appAccent = Color.accentColor

    // MARK: — Puntos
    /// Verde para acciones que suman puntos.
    static let appPositive = Color.green
    /// Rojo para acciones que restan puntos.
    static let appNegative = Color.red
    /// Naranja para advertencias (cupo alto, puntos insuficientes).
    static let appWarning = Color.orange

    // MARK: — Texto (adaptativos)
    static let appPrimary = Color.primary
    static let appSecondary = Color.secondary

    // MARK: — Hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8)  & 0xFF) / 255
        let b = Double( value        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}
