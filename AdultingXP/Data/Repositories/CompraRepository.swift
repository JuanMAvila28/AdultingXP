struct CompraRepository: CompraRepositoryProtocol {
    private let filename = "compras.json"

    func cargar() -> [Compra] {
        JSONStore.load([Compra].self, fromFile: filename) ?? []
    }

    func guardar(_ compras: [Compra]) {
        JSONStore.save(compras, toFile: filename)
    }
}
