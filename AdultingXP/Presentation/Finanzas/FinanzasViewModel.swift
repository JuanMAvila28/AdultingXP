import Foundation
import Observation

@Observable
final class FinanzasViewModel {
    private let tarjetaRepo: any TarjetaCreditoRepositoryProtocol
    private let compraRepo: any CompraRepositoryProtocol

    var tarjetas: [TarjetaCredito] = []
    var compras: [Compra] = []

    var deudaGlobal: Double {
        tarjetas.reduce(0) { $0 + deudaTotal(de: $1) }
    }

    init(
        tarjetaRepo: any TarjetaCreditoRepositoryProtocol = TarjetaCreditoRepository(),
        compraRepo: any CompraRepositoryProtocol = CompraRepository()
    ) {
        self.tarjetaRepo = tarjetaRepo
        self.compraRepo = compraRepo
        tarjetas = tarjetaRepo.cargar()
        compras = compraRepo.cargar()
    }

    // MARK: — Acciones

    func agregar(_ tarjeta: TarjetaCredito) {
        tarjetas.append(tarjeta)
        tarjetaRepo.guardar(tarjetas)
    }

    func actualizar(_ tarjeta: TarjetaCredito) {
        guard let i = tarjetas.firstIndex(where: { $0.id == tarjeta.id }) else { return }
        tarjetas[i] = tarjeta
        tarjetaRepo.guardar(tarjetas)
    }

    func eliminar(_ tarjeta: TarjetaCredito) {
        compras.removeAll { $0.tarjetaId == tarjeta.id }
        compraRepo.guardar(compras)
        tarjetas.removeAll { $0.id == tarjeta.id }
        tarjetaRepo.guardar(tarjetas)
    }

    func agregarCompra(_ compra: Compra) {
        compras.append(compra)
        compraRepo.guardar(compras)
    }

    func actualizarCompra(_ compra: Compra) {
        guard let i = compras.firstIndex(where: { $0.id == compra.id }) else { return }
        compras[i] = compra
        compraRepo.guardar(compras)
    }

    func eliminarCompra(_ compra: Compra) {
        compras.removeAll { $0.id == compra.id }
        compraRepo.guardar(compras)
    }

    // MARK: — Consultas por tarjeta

    func compras(de tarjeta: TarjetaCredito) -> [Compra] {
        compras.filter { $0.tarjetaId == tarjeta.id }
    }

    func deudaTotal(de tarjeta: TarjetaCredito) -> Double {
        compras(de: tarjeta)
            .filter { !$0.estaPagada(diaCorte: tarjeta.diaCorte) }
            .reduce(0) { $0 + $1.saldoPendiente(diaCorte: tarjeta.diaCorte) }
    }

    func cuotaMes(de tarjeta: TarjetaCredito) -> Double {
        compras(de: tarjeta)
            .filter { !$0.estaPagada(diaCorte: tarjeta.diaCorte) }
            .reduce(0) { $0 + $1.montoPorCuota }
    }

    func cupoDisponible(de tarjeta: TarjetaCredito) -> Double {
        tarjeta.limiteCredito - deudaTotal(de: tarjeta)
    }

    // MARK: — Forecast

    struct PagoMensual: Identifiable {
        let id = UUID()
        let mes: Date
        let total: Double
    }

    func forecastMensual(de tarjeta: TarjetaCredito, meses: Int = 3) -> [PagoMensual] {
        let cal = Calendar.current
        let activas = compras(de: tarjeta).filter { !$0.estaPagada(diaCorte: tarjeta.diaCorte) }
        return (1...meses).map { offset -> PagoMensual in
            let mes = cal.date(byAdding: .month, value: offset, to: .now)!
            var corteMes = cal.dateComponents([.year, .month], from: mes)
            corteMes.day = tarjeta.diaCorte
            let fechaCorte = cal.date(from: corteMes) ?? mes

            let total = activas.reduce(0.0) { acum, compra in
                let billedFuturo = compra.cuotasBilledAt(fechaCorte, diaCorte: tarjeta.diaCorte)
                let billedActual = compra.cuotasBilled(diaCorte: tarjeta.diaCorte)
                return billedFuturo > billedActual && billedFuturo <= compra.numeroCuotas
                    ? acum + compra.montoPorCuota
                    : acum
            }
            return PagoMensual(mes: mes, total: total)
        }
    }

    // MARK: — Gráfica

    struct DatoDeuda: Identifiable {
        let id: UUID
        let nombre: String
        let deuda: Double
        let colorHex: String
    }

    var datosGraficaDeuda: [DatoDeuda] {
        tarjetas
            .map { DatoDeuda(id: $0.id, nombre: $0.nombre, deuda: deudaTotal(de: $0), colorHex: $0.colorHex) }
            .filter { $0.deuda > 0 }
    }
}
