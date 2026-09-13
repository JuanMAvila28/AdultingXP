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
}
