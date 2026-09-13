import Foundation

struct HabitoRepository: HabitoRepositoryProtocol {
    private let filename = "habitos.json"

    func cargar() -> [Habito] {
        JSONStore.load([Habito].self, fromFile: filename) ?? []
    }

    func guardar(_ habitos: [Habito]) {
        JSONStore.save(habitos, toFile: filename)
    }
}
