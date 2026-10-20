struct PagoRepository: PagoRepositoryProtocol {
    private let filename = "pagos.json"

    func cargar() -> [Pago] {
        JSONStore.load([Pago].self, fromFile: filename) ?? []
    }

    func guardar(_ pagos: [Pago]) {
        JSONStore.save(pagos, toFile: filename)
    }
}
