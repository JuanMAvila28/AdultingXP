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

struct Habito: Identifiable, Hashable {
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
    /// Posición dentro de su categoría. 0 para hábitos migrados (preserva orden del array).
    var orden: Int

    init(
        id: UUID = UUID(),
        nombre: String,
        emoji: String,
        categoria: String,
        esBueno: Bool = true,
        puntajeBase: Int,
        frecuencia: FrecuenciaHabito = .diario,
        streakActual: Int = 0,
        fechaUltimaCompletacion: Date? = nil,
        orden: Int = 0
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
        self.orden = orden
    }
}

// MARK: — Codable (manual para compatibilidad con JSON previo sin `orden`)

extension Habito: Codable {
    enum CodingKeys: String, CodingKey {
        case id, nombre, emoji, categoria, esBueno, puntajeBase
        case frecuencia, streakActual, fechaUltimaCompletacion, orden
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                     = try c.decode(UUID.self,            forKey: .id)
        nombre                 = try c.decode(String.self,          forKey: .nombre)
        emoji                  = try c.decode(String.self,          forKey: .emoji)
        categoria              = try c.decode(String.self,          forKey: .categoria)
        esBueno                = try c.decode(Bool.self,            forKey: .esBueno)
        puntajeBase            = try c.decode(Int.self,             forKey: .puntajeBase)
        frecuencia             = try c.decode(FrecuenciaHabito.self, forKey: .frecuencia)
        streakActual           = try c.decode(Int.self,             forKey: .streakActual)
        fechaUltimaCompletacion = try c.decodeIfPresent(Date.self,  forKey: .fechaUltimaCompletacion)
        orden                  = try c.decodeIfPresent(Int.self,    forKey: .orden) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                      forKey: .id)
        try c.encode(nombre,                  forKey: .nombre)
        try c.encode(emoji,                   forKey: .emoji)
        try c.encode(categoria,               forKey: .categoria)
        try c.encode(esBueno,                 forKey: .esBueno)
        try c.encode(puntajeBase,             forKey: .puntajeBase)
        try c.encode(frecuencia,              forKey: .frecuencia)
        try c.encode(streakActual,            forKey: .streakActual)
        try c.encodeIfPresent(fechaUltimaCompletacion, forKey: .fechaUltimaCompletacion)
        try c.encode(orden,                   forKey: .orden)
    }
}
