import Foundation

struct ComprarConTarjetaUseCase {
    private let compraRepo: any CompraRepositoryProtocol

    init(compraRepo: any CompraRepositoryProtocol = CompraRepository()) {
        self.compraRepo = compraRepo
    }

    func ejecutar(item: ItemWishlist, tarjetaId: UUID, numeroCuotas: Int, tasaCambio: Double) {
        let monto = Double(item.costoEnPuntos) * tasaCambio
        let compra = Compra(
            tarjetaId: tarjetaId,
            descripcion: "\(item.emoji) \(item.nombre)",
            montoTotal: monto,
            numeroCuotas: numeroCuotas
        )
        compraRepo.guardar(compraRepo.cargar() + [compra])
    }
}
