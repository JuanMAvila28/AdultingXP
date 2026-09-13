import Foundation
import Observation

@Observable
final class HabitosViewModel {

    private let habitoRepo: any HabitoRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol
    private let completarUseCase: CompletarHabitoUseCase

    var habitos: [Habito] = []
    var registros: [RegistroPuntos] = []
    var filtroCategoria: String? = nil

    var balanceGlobal: Int {
        registros.reduce(0) { $0 + $1.cantidad }
    }

    var categorias: [String] {
        Array(Set(habitos.map(\.categoria))).sorted()
    }

    var habitosAgrupados: [(categoria: String, items: [Habito])] {
        let fuente = filtroCategoria.map { f in habitos.filter { $0.categoria == f } } ?? habitos
        let agrupados = Dictionary(grouping: fuente, by: \.categoria)
        return agrupados.keys.sorted().map { cat in (categoria: cat, items: agrupados[cat] ?? []) }
    }

    init(
        habitoRepo: any HabitoRepositoryProtocol = HabitoRepository(),
        registroRepo: any RegistroPuntosRepositoryProtocol = RegistroPuntosRepository()
    ) {
        self.habitoRepo = habitoRepo
        self.registroRepo = registroRepo
        self.completarUseCase = CompletarHabitoUseCase(habitoRepo: habitoRepo, registroRepo: registroRepo)
        habitos = habitoRepo.cargar()
        registros = registroRepo.cargar()
        resetearRachasRotas()
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
        let resultado = completarUseCase.ejecutar(
            habito: habito,
            todosLosHabitos: habitos,
            registrosActuales: registros
        )
        if let i = habitos.firstIndex(where: { $0.id == resultado.habitoActualizado.id }) {
            habitos[i] = resultado.habitoActualizado
        }
        registros.append(contentsOf: resultado.nuevosRegistros)
    }

    // MARK: — Reset de rachas

    func recargar() {
        habitos = habitoRepo.cargar()
        registros = registroRepo.cargar()
        resetearRachasRotas()
    }

    func resetearRachasRotas() {
        habitos = completarUseCase.resetearRachasRotas(habitos: habitos)
    }

    // MARK: — Consultas

    func estaCompletadoHoy(_ habito: Habito) -> Bool {
        guard let fecha = habito.fechaUltimaCompletacion else { return false }
        return Calendar.current.isDateInToday(fecha)
    }
}
