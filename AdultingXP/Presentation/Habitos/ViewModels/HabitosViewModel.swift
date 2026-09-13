import Foundation
import Observation

@Observable
final class HabitosViewModel {

    var habitos: [Habito] = []
    var registros: [RegistroPuntos] = []

    var balanceGlobal: Int {
        registros.reduce(0) { $0 + $1.cantidad }
    }

    init() {
        habitos   = JSONStore.load([Habito].self,          fromFile: "habitos.json")   ?? []
        registros = JSONStore.load([RegistroPuntos].self,  fromFile: "registros.json") ?? []
    }

    // MARK: — Acciones

    func agregar(_ habito: Habito) {
        habitos.append(habito)
        JSONStore.save(habitos, toFile: "habitos.json")
    }

    func actualizar(_ habito: Habito) {
        guard let index = habitos.firstIndex(where: { $0.id == habito.id }) else { return }
        habitos[index] = habito
        JSONStore.save(habitos, toFile: "habitos.json")
    }

    func eliminar(_ habito: Habito) {
        habitos.removeAll { $0.id == habito.id }
        JSONStore.save(habitos, toFile: "habitos.json")
        // Los RegistroPuntos históricos se conservan — son el ledger inmutable.
    }

    func completar(_ habito: Habito) {
        guard let index = habitos.firstIndex(where: { $0.id == habito.id }) else { return }

        habitos[index].fechaUltimaCompletacion = .now
        JSONStore.save(habitos, toFile: "habitos.json")

        let delta = habito.esBueno ? habito.puntajeBase : -habito.puntajeBase
        let registro = RegistroPuntos(
            cantidad: delta,
            concepto: habito.nombre,
            origen: .habito
        )
        registros.append(registro)
        JSONStore.save(registros, toFile: "registros.json")
    }

    // MARK: — Consultas

    func estaCompletadoHoy(_ habito: Habito) -> Bool {
        guard let fecha = habito.fechaUltimaCompletacion else { return false }
        return Calendar.current.isDateInToday(fecha)
    }
}
