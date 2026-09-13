import Foundation
import Observation

@Observable
final class HabitosViewModel {

    private let habitoRepo: any HabitoRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

    var habitos: [Habito] = []
    var registros: [RegistroPuntos] = []

    var balanceGlobal: Int {
        registros.reduce(0) { $0 + $1.cantidad }
    }

    init(
        habitoRepo: any HabitoRepositoryProtocol = HabitoRepository(),
        registroRepo: any RegistroPuntosRepositoryProtocol = RegistroPuntosRepository()
    ) {
        self.habitoRepo = habitoRepo
        self.registroRepo = registroRepo
        habitos = habitoRepo.cargar()
        registros = registroRepo.cargar()
    }

    // MARK: — Acciones

    func agregar(_ habito: Habito) {
        habitos.append(habito)
        habitoRepo.guardar(habitos)
    }

    func actualizar(_ habito: Habito) {
        guard let index = habitos.firstIndex(where: { $0.id == habito.id }) else { return }
        habitos[index] = habito
        habitoRepo.guardar(habitos)
    }

    func eliminar(_ habito: Habito) {
        habitos.removeAll { $0.id == habito.id }
        habitoRepo.guardar(habitos)
    }

    func completar(_ habito: Habito) {
        guard let index = habitos.firstIndex(where: { $0.id == habito.id }) else { return }
        habitos[index].fechaUltimaCompletacion = .now
        habitoRepo.guardar(habitos)

        let delta = habito.esBueno ? habito.puntajeBase : -habito.puntajeBase
        let registro = RegistroPuntos(
            cantidad: delta,
            concepto: habito.nombre,
            origen: .habito
        )
        registros.append(registro)
        registroRepo.guardar(registros)
    }

    // MARK: — Consultas

    func estaCompletadoHoy(_ habito: Habito) -> Bool {
        guard let fecha = habito.fechaUltimaCompletacion else { return false }
        return Calendar.current.isDateInToday(fecha)
    }
}
