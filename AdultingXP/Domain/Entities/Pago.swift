import Foundation

struct Pago: Identifiable, Codable {
    let id: UUID
    let tarjetaId: UUID
    var fechaPago: Date
    var montoPagado: Double
    /// Valor a pagar calculado en el momento de registrar el pago.
    /// Se congela aquí para que futuros cambios en compras no lo alteren retroactivamente.
    var balanceAntes: Double

    init(
        id: UUID = UUID(),
        tarjetaId: UUID,
        fechaPago: Date = .now,
        montoPagado: Double,
        balanceAntes: Double
    ) {
        self.id = id
        self.tarjetaId = tarjetaId
        self.fechaPago = fechaPago
        self.montoPagado = montoPagado
        self.balanceAntes = balanceAntes
    }
}
