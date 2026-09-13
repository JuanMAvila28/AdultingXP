protocol CompraRepositoryProtocol {
    func cargar() -> [Compra]
    func guardar(_ compras: [Compra])
}
