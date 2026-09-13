struct WishlistRepository: WishlistRepositoryProtocol {
    private let filename = "wishlist.json"

    func cargar() -> [ItemWishlist] {
        JSONStore.load([ItemWishlist].self, fromFile: filename) ?? []
    }

    func guardar(_ items: [ItemWishlist]) {
        JSONStore.save(items, toFile: filename)
    }
}
