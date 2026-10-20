protocol PagoRepositoryProtocol {
    func cargar() -> [Pago]
    func guardar(_ pagos: [Pago])
}
