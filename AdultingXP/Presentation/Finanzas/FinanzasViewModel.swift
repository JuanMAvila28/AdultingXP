import Foundation
import Observation

@Observable
final class FinanzasViewModel {
    private let tarjetaRepo: any TarjetaCreditoRepositoryProtocol
    private let compraRepo: any CompraRepositoryProtocol
    private let pagoRepo: any PagoRepositoryProtocol

    var tarjetas: [TarjetaCredito] = []
    var compras: [Compra] = []
    var pagos: [Pago] = []

    var deudaGlobal: Double {
        tarjetas.reduce(0) { $0 + deudaTotal(de: $1) }
    }

    init(
        tarjetaRepo: any TarjetaCreditoRepositoryProtocol = TarjetaCreditoRepository(),
        compraRepo: any CompraRepositoryProtocol = CompraRepository(),
        pagoRepo: any PagoRepositoryProtocol = PagoRepository()
    ) {
        self.tarjetaRepo = tarjetaRepo
        self.compraRepo = compraRepo
        self.pagoRepo = pagoRepo
        tarjetas = tarjetaRepo.cargar()
        compras = compraRepo.cargar()
        pagos = pagoRepo.cargar()
    }

    // MARK: — Acciones tarjetas

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
        pagos.removeAll { $0.tarjetaId == tarjeta.id }
        pagoRepo.guardar(pagos)
        tarjetas.removeAll { $0.id == tarjeta.id }
        tarjetaRepo.guardar(tarjetas)
    }

    // MARK: — Acciones compras

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

    // MARK: — Acciones pagos

    func agregarPago(_ pago: Pago) {
        pagos.append(pago)
        pagoRepo.guardar(pagos)
    }

    func eliminarPago(_ pago: Pago) {
        pagos.removeAll { $0.id == pago.id }
        pagoRepo.guardar(pagos)
    }

    // MARK: — Consultas por tarjeta

    func compras(de tarjeta: TarjetaCredito) -> [Compra] {
        compras.filter { $0.tarjetaId == tarjeta.id }
    }

    func pagos(de tarjeta: TarjetaCredito) -> [Pago] {
        pagos
            .filter { $0.tarjetaId == tarjeta.id }
            .sorted { $0.fechaPago < $1.fechaPago }
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

    /// Saldo del mes anterior que no fue pagado, derivado del último pago registrado.
    func saldoAnterior(de tarjeta: TarjetaCredito) -> Double {
        guard let ultimo = pagos(de: tarjeta).last else { return 0 }
        return max(0, ultimo.balanceAntes - ultimo.montoPagado)
    }

    /// Total real a pagar este mes: cuotas + cuota de manejo + saldo anterior no pagado.
    func valorAPagar(de tarjeta: TarjetaCredito) -> Double {
        cuotaMes(de: tarjeta)
        + (tarjeta.cuotaManejo ?? 0)
        + saldoAnterior(de: tarjeta)
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

            let cuotas = activas.reduce(0.0) { acum, compra in
                let billedFuturo  = compra.cuotasBilledAt(fechaCorte, diaCorte: tarjeta.diaCorte)
                let billedActual  = compra.cuotasBilled(diaCorte: tarjeta.diaCorte)
                return billedFuturo > billedActual && billedFuturo <= compra.numeroCuotas
                    ? acum + compra.montoPorCuota
                    : acum
            }
            let total = cuotas + (tarjeta.cuotaManejo ?? 0)
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
