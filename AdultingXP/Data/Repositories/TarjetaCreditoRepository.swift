struct TarjetaCreditoRepository: TarjetaCreditoRepositoryProtocol {
    private let filename = "tarjetas.json"

    func cargar() -> [TarjetaCredito] {
        JSONStore.load([TarjetaCredito].self, fromFile: filename) ?? []
    }

    func guardar(_ tarjetas: [TarjetaCredito]) {
        JSONStore.save(tarjetas, toFile: filename)
    }
}
