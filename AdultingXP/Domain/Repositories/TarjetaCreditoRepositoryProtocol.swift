protocol TarjetaCreditoRepositoryProtocol {
    func cargar() -> [TarjetaCredito]
    func guardar(_ tarjetas: [TarjetaCredito])
}
