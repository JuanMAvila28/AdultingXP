import Foundation

struct RegistroTiempoPantallaRepository: RegistroTiempoPantallaRepositoryProtocol {
    private let filename = "tiempo_pantalla.json"

    func cargar() -> [RegistroTiempoPantalla] {
        JSONStore.load([RegistroTiempoPantalla].self, fromFile: filename) ?? []
    }

    func guardar(_ registros: [RegistroTiempoPantalla]) {
        JSONStore.save(registros, toFile: filename)
    }
}
