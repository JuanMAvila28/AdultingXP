import Foundation
import Observation

@Observable
final class WishlistViewModel {
    private let wishlistRepo: any WishlistRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

    var items: [ItemWishlist] = []
    var registros: [RegistroPuntos] = []

    var balanceGlobal: Int {
        registros.reduce(0) { $0 + $1.cantidad }
    }

    var itemsPendientes: [ItemWishlist] {
        items.filter { !$0.reclamado }
    }

    var itemsReclamados: [ItemWishlist] {
        items.filter { $0.reclamado }
    }

    init(
        wishlistRepo: any WishlistRepositoryProtocol = WishlistRepository(),
        registroRepo: any RegistroPuntosRepositoryProtocol = RegistroPuntosRepository()
    ) {
        self.wishlistRepo = wishlistRepo
        self.registroRepo = registroRepo
        items = wishlistRepo.cargar()
        registros = registroRepo.cargar()
    }

    // MARK: — Acciones

    func agregar(_ item: ItemWishlist) {
        items.append(item)
        wishlistRepo.guardar(items)
    }

    func eliminar(_ item: ItemWishlist) {
        items.removeAll { $0.id == item.id }
        wishlistRepo.guardar(items)
    }

    // MARK: — Consultas

    func progreso(para item: ItemWishlist) -> Double {
        guard item.costoEnPuntos > 0 else { return 1.0 }
        return min(1.0, max(0, Double(balanceGlobal) / Double(item.costoEnPuntos)))
    }

    func puedeReclamar(_ item: ItemWishlist) -> Bool {
        !item.reclamado && balanceGlobal >= item.costoEnPuntos
    }
}
