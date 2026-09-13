import Foundation

struct RegistroPuntosRepository: RegistroPuntosRepositoryProtocol {
    private let filename = "registros.json"

    func cargar() -> [RegistroPuntos] {
        JSONStore.load([RegistroPuntos].self, fromFile: filename) ?? []
    }

    func guardar(_ registros: [RegistroPuntos]) {
        JSONStore.save(registros, toFile: filename)
    }
}
