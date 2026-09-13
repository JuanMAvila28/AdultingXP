import Foundation
import Observation

@Observable
final class HabitosViewModel {

    var habitos: [Habito] = []

    init() {
        habitos = JSONStore.load([Habito].self, fromFile: "habitos.json") ?? []
    }

    func agregar(_ habito: Habito) {
        habitos.append(habito)
        JSONStore.save(habitos, toFile: "habitos.json")
    }
}
