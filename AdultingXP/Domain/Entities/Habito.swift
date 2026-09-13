import Foundation

enum FrecuenciaHabito: String, Codable, CaseIterable {
    case diario
    case semanal

    var label: String {
        switch self {
        case .diario:  "Diario"
        case .semanal: "Semanal"
        }
    }
}

struct Habito: Identifiable, Codable, Hashable {
    let id: UUID
    var nombre: String
    var emoji: String
    var categoria: String
    /// true → hábito bueno (suma puntos), false → hábito malo (resta puntos).
    var esBueno: Bool
    /// Magnitud del puntaje — siempre positivo. El signo lo aplica el UseCase según esBueno.
    var puntajeBase: Int
    var frecuencia: FrecuenciaHabito
    var streakActual: Int
    var fechaUltimaCompletacion: Date?

    init(
        id: UUID = UUID(),
        nombre: String,
        emoji: String,
        categoria: String,
        esBueno: Bool = true,
        puntajeBase: Int,
        frecuencia: FrecuenciaHabito = .diario,
        streakActual: Int = 0,
        fechaUltimaCompletacion: Date? = nil
    ) {
        self.id = id
        self.nombre = nombre
        self.emoji = emoji
        self.categoria = categoria
        self.esBueno = esBueno
        self.puntajeBase = puntajeBase
        self.frecuencia = frecuencia
        self.streakActual = streakActual
        self.fechaUltimaCompletacion = fechaUltimaCompletacion
    }
}
