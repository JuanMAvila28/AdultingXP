import Foundation

struct TarjetaCredito: Identifiable, Codable, Hashable {
    let id: UUID
    var nombre: String
    var banco: String
    var limiteCredito: Double
    var diaCorte: Int   // 1–28
    var diaPago: Int    // 1–28
    var colorHex: String

    init(
        id: UUID = UUID(),
        nombre: String,
        banco: String,
        limiteCredito: Double,
        diaCorte: Int,
        diaPago: Int,
        colorHex: String = "#5E4ADB"
    ) {
        self.id = id
        self.nombre = nombre
        self.banco = banco
        self.limiteCredito = limiteCredito
        self.diaCorte = diaCorte
        self.diaPago = diaPago
        self.colorHex = colorHex
    }
}
