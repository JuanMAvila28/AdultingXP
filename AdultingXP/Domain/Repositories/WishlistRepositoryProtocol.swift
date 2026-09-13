protocol WishlistRepositoryProtocol {
    func cargar() -> [ItemWishlist]
    func guardar(_ items: [ItemWishlist])
}
