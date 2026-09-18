import Foundation

enum OrigenPuntos: String, Codable, CaseIterable {
    case habito
    case tarea
    case wishlist
    case bonusStreak
    case pomodoro
    case tiempoPantalla

    var label: String {
        switch self {
        case .habito:         "Hábito"
        case .tarea:          "Tarea"
        case .wishlist:       "Wishlist"
        case .bonusStreak:    "Bonus Racha"
        case .pomodoro:       "Pomodoro"
        case .tiempoPantalla: "Pantalla"
        }
    }
}

/// Registro inmutable de una transacción de puntos.
/// El balance global se computa sumando todos los registros — nunca se guarda como número.
struct RegistroPuntos: Identifiable, Codable, Hashable {
    let id: UUID
    let fecha: Date
    /// Positivo: suma puntos. Negativo: resta puntos.
    let cantidad: Int
    let concepto: String
    let origen: OrigenPuntos

    init(
        id: UUID = UUID(),
        fecha: Date = .now,
        cantidad: Int,
        concepto: String,
        origen: OrigenPuntos
    ) {
        self.id = id
        self.fecha = fecha
        self.cantidad = cantidad
        self.concepto = concepto
        self.origen = origen
    }
}
