import Foundation

struct Compra: Identifiable, Codable, Hashable {
    let id: UUID
    let tarjetaId: UUID
    var descripcion: String
    var montoTotal: Double
    var numeroCuotas: Int
    var fechaCompra: Date

    init(
        id: UUID = UUID(),
        tarjetaId: UUID,
        descripcion: String,
        montoTotal: Double,
        numeroCuotas: Int = 1,
        fechaCompra: Date = .now
    ) {
        self.id = id
        self.tarjetaId = tarjetaId
        self.descripcion = descripcion
        self.montoTotal = montoTotal
        self.numeroCuotas = numeroCuotas
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
