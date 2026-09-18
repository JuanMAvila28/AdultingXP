import Foundation

struct Compra: Identifiable, Hashable {
    let id: UUID
    let tarjetaId: UUID
    var descripcion: String
    var montoTotal: Double
    var numeroCuotas: Int
    var tieneInteres: Bool
    var fechaCompra: Date

    init(
        id: UUID = UUID(),
        tarjetaId: UUID,
        descripcion: String,
        montoTotal: Double,
        numeroCuotas: Int = 1,
        tieneInteres: Bool = false,
        fechaCompra: Date = .now
    ) {
        self.id = id
        self.tarjetaId = tarjetaId
        self.descripcion = descripcion
        self.montoTotal = montoTotal
        self.numeroCuotas = numeroCuotas
        self.tieneInteres = tieneInteres
        self.fechaCompra = fechaCompra
    }

    var montoPorCuota: Double {
        montoTotal / Double(max(1, numeroCuotas))
    }

    /// Cuántas cuotas ya han sido facturadas en el extracto, dado el día de corte de la tarjeta.
    /// Cada ciclo de facturación comienza en `diaCorte` del mes.
    func cuotasBilled(diaCorte: Int) -> Int {
        let calendar = Calendar.current
        let hoy = Date.now

        // Primer corte posterior a la compra
        var components = calendar.dateComponents([.year, .month], from: fechaCompra)
        components.day = diaCorte
        guard var primerCorte = calendar.date(from: components) else { return 0 }
        if primerCorte <= fechaCompra {
            primerCorte = calendar.date(byAdding: .month, value: 1, to: primerCorte) ?? primerCorte
        }

        guard hoy >= primerCorte else { return 0 }

        let meses = calendar.dateComponents([.month], from: primerCorte, to: hoy).month ?? 0
        return min(numeroCuotas, meses + 1)
    }

    func cuotasBilledAt(_ fecha: Date, diaCorte: Int) -> Int {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: fechaCompra)
        components.day = diaCorte
        guard var primerCorte = calendar.date(from: components) else { return 0 }
        if primerCorte <= fechaCompra {
            primerCorte = calendar.date(byAdding: .month, value: 1, to: primerCorte) ?? primerCorte
        }
        guard fecha >= primerCorte else { return 0 }
        let meses = calendar.dateComponents([.month], from: primerCorte, to: fecha).month ?? 0
        return min(numeroCuotas, meses + 1)
    }

    func cuotasRestantes(diaCorte: Int) -> Int {
        max(0, numeroCuotas - cuotasBilled(diaCorte: diaCorte))
    }

    func saldoPendiente(diaCorte: Int) -> Double {
        montoPorCuota * Double(cuotasRestantes(diaCorte: diaCorte))
    }

    func estaPagada(diaCorte: Int) -> Bool {
        cuotasRestantes(diaCorte: diaCorte) == 0
    }
}

// MARK: — Codable (manual para compatibilidad con JSON previo que no tiene `tieneInteres`)

extension Compra: Codable {
    enum CodingKeys: String, CodingKey {
        case id, tarjetaId, descripcion, montoTotal, numeroCuotas, tieneInteres, fechaCompra
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id           = try c.decode(UUID.self,   forKey: .id)
        tarjetaId    = try c.decode(UUID.self,   forKey: .tarjetaId)
        descripcion  = try c.decode(String.self, forKey: .descripcion)
        montoTotal   = try c.decode(Double.self, forKey: .montoTotal)
        numeroCuotas = try c.decode(Int.self,    forKey: .numeroCuotas)
        tieneInteres = try c.decodeIfPresent(Bool.self, forKey: .tieneInteres) ?? false
        fechaCompra  = try c.decode(Date.self,   forKey: .fechaCompra)
    }
}
