import Foundation
import Observation

@Observable
final class HabitosViewModel {

    var habitos: [Habito] = []

    init() {
        habitos = JSONStore.load([Habito].self, fromFile: "habitos.json") ?? Self.sampleData
    }
}

// MARK: — Datos de prueba (se eliminan en CH-1.4 cuando exista creación real)

private extension HabitosViewModel {
    static let sampleData: [Habito] = [
        Habito(nombre: "Levantarse temprano", emoji: "🌅", categoria: "Salud",     esBueno: true,  puntajeBase: 10, frecuencia: .diario),
        Habito(nombre: "Hacer ejercicio",     emoji: "💪", categoria: "Salud",     esBueno: true,  puntajeBase: 15, frecuencia: .diario),
        Habito(nombre: "Leer 30 minutos",     emoji: "📚", categoria: "Estudio",   esBueno: true,  puntajeBase: 10, frecuencia: .diario),
        Habito(nombre: "Sacar la basura",     emoji: "🗑️", categoria: "Hogar",     esBueno: true,  puntajeBase: 5,  frecuencia: .semanal),
        Habito(nombre: "Redes sociales",      emoji: "📱", categoria: "Bienestar", esBueno: false, puntajeBase: 5,  frecuencia: .diario),
    ]
}
