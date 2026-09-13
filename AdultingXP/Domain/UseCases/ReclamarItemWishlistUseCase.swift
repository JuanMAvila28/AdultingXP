import Foundation

struct ReclamarItemWishlistUseCase {
    private let wishlistRepo: any WishlistRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

    init(
        wishlistRepo: any WishlistRepositoryProtocol,
        registroRepo: any RegistroPuntosRepositoryProtocol
    ) {
        self.wishlistRepo = wishlistRepo
        self.registroRepo = registroRepo
    }

    struct Resultado {
        let itemActualizado: ItemWishlist
        let nuevoRegistro: RegistroPuntos
    }

    func ejecutar(
        item: ItemWishlist,
        todosLosItems: [ItemWishlist],
        registrosActuales: [RegistroPuntos]
    ) -> Resultado {
        var actualizado = item
        actualizado.reclamado = true
        actualizado.fechaReclamado = .now

        var itemsActualizados = todosLosItems
        if let i = itemsActualizados.firstIndex(where: { $0.id == item.id }) {
            itemsActualizados[i] = actualizado
        }
        wishlistRepo.guardar(itemsActualizados)

        let registro = RegistroPuntos(
            cantidad: -item.costoEnPuntos,
            concepto: "\(item.emoji) \(item.nombre)",
            origen: .wishlist
        )
        registroRepo.guardar(registrosActuales + [registro])

        return Resultado(itemActualizado: actualizado, nuevoRegistro: registro)
    }
}
