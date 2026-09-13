import Foundation

protocol HabitoRepositoryProtocol {
    func cargar() -> [Habito]
    func guardar(_ habitos: [Habito])
}
