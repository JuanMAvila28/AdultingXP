import Foundation

struct TarjetaCredito: Identifiable, Codable, Hashable {
    let id: UUID
    var nombre: String
    var banco: String
    var limiteCredito: Double
    var diaCorte: Int   // 1–31
    var diaPago: Int    // 1–31
    var colorHex: String
    var cuotaManejo: Double?    // nil = sin cuota de manejo; valor = monto mensual
    var tasaInteres: Double?    // nil = sin interés; valor = % mensual efectivo

    init(
        id: UUID = UUID(),
        nombre: String,
        banco: String,
        limiteCredito: Double,
        diaCorte: Int,
        diaPago: Int,
        colorHex: String = "#5E4ADB",
        cuotaManejo: Double? = nil,
        tasaInteres: Double? = nil
    ) {
        self.id = id
        self.nombre = nombre
        self.banco = banco
        self.limiteCredito = limiteCredito
        self.diaCorte = diaCorte
        self.diaPago = diaPago
        self.colorHex = colorHex
        self.cuotaManejo = cuotaManejo
        self.tasaInteres = tasaInteres
    }
}
