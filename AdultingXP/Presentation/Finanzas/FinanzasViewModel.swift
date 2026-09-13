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
}
