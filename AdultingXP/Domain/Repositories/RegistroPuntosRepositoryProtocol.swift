import Foundation

protocol RegistroPuntosRepositoryProtocol {
    func cargar() -> [RegistroPuntos]
    func guardar(_ registros: [RegistroPuntos])
}
