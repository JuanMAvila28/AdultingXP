import Foundation

struct Tarea: Identifiable, Codable, Hashable {
    let id: UUID
    var titulo: String
    var materia: String
    var fechaLimite: Date
    var puntajeBase: Int
    var completada: Bool
    var fechaCompletada: Date?

    init(
        id: UUID = UUID(),
        titulo: String,
        materia: String,
        fechaLimite: Date,
        puntajeBase: Int = 10,
        completada: Bool = false,
        fechaCompletada: Date? = nil
    ) {
        self.id = id
        self.titulo = titulo
        self.materia = materia
        self.fechaLimite = fechaLimite
        self.puntajeBase = puntajeBase
        self.completada = completada
        self.fechaCompletada = fechaCompletada
    }

    var estaVencida: Bool {
        !completada && .now > fechaLimite
    }

    var fueCompletadaATiempo: Bool? {
        guard let fechaCompletada else { return nil }
        return fechaCompletada <= fechaLimite
    }
}
