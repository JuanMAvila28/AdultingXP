import Foundation

struct ItemWishlist: Identifiable, Codable, Hashable {
    let id: UUID
    var nombre: String
    var emoji: String
    var costoEnPuntos: Int
    var descripcion: String
    var reclamado: Bool
    var fechaReclamado: Date?

    init(
        id: UUID = UUID(),
        nombre: String,
        emoji: String,
        costoEnPuntos: Int,
        descripcion: String = "",
        reclamado: Bool = false,
        fechaReclamado: Date? = nil
    ) {
        self.id = id
        self.nombre = nombre
        self.emoji = emoji
        self.costoEnPuntos = costoEnPuntos
        self.descripcion = descripcion
        self.reclamado = reclamado
        self.fechaReclamado = fechaReclamado
    }
}
