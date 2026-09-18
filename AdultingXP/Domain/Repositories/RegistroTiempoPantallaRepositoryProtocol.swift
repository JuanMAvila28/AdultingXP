import Foundation

protocol RegistroTiempoPantallaRepositoryProtocol {
    func cargar() -> [RegistroTiempoPantalla]
    func guardar(_ registros: [RegistroTiempoPantalla])
}
