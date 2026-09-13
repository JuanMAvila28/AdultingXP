import Foundation
import Observation

@Observable
final class WishlistViewModel {
    private let wishlistRepo: any WishlistRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol
    private let reclamarUseCase: ReclamarItemWishlistUseCase

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
        self.reclamarUseCase = ReclamarItemWishlistUseCase(wishlistRepo: wishlistRepo, registroRepo: registroRepo)
        items = wishlistRepo.cargar()
        registros = registroRepo.cargar()
    }

    // MARK: — Acciones

    func recargarRegistros() {
        registros = registroRepo.cargar()
    }

    func agregar(_ item: ItemWishlist) {
        items.append(item)
        wishlistRepo.guardar(items)
    }

    func eliminar(_ item: ItemWishlist) {
        items.removeAll { $0.id == item.id }
        wishlistRepo.guardar(items)
    }

    func reclamar(_ item: ItemWishlist) {
        guard puedeReclamar(item) else { return }
        let resultado = reclamarUseCase.ejecutar(
            item: item,
            todosLosItems: items,
            registrosActuales: registros
        )
        if let i = items.firstIndex(where: { $0.id == resultado.itemActualizado.id }) {
            items[i] = resultado.itemActualizado
        }
        registros.append(resultado.nuevoRegistro)
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
