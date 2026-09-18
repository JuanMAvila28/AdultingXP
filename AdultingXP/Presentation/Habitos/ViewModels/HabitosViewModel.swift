import Foundation
import Observation

@Observable
final class HabitosViewModel {

    private let habitoRepo: any HabitoRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol
    private let registrarUseCase: RegistrarOcurrenciaHabitoUseCase

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
        self.registrarUseCase = RegistrarOcurrenciaHabitoUseCase(
            habitoRepo: habitoRepo,
            registroRepo: registroRepo
        )
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

    /// Registra una ocurrencia del hábito. Devuelve el ID del RegistroPuntos creado (para undo).
    @discardableResult
    func registrar(_ habito: Habito) -> UUID? {
        let resultado = registrarUseCase.ejecutar(
            habito: habito,
            todosLosHabitos: habitos,
            registrosActuales: registros
        )
        if let i = habitos.firstIndex(where: { $0.id == resultado.habitoActualizado.id }) {
            habitos[i] = resultado.habitoActualizado
        }
        registros.append(contentsOf: resultado.nuevosRegistros)
        return resultado.nuevosRegistros.first?.id
    }

    /// Revierte la ocurrencia con el ID dado y restaura el hábito a su estado previo.
    func deshacer(habitoAntes: Habito, registroId: UUID) {
        let resultado = registrarUseCase.deshacerConRegistro(
            habitoAntes: habitoAntes,
            registroId: registroId,
            todosLosHabitos: habitos,
            registrosActuales: registros
        )
        if let i = habitos.firstIndex(where: { $0.id == resultado.habitoRestaurado.id }) {
            habitos[i] = resultado.habitoRestaurado
        }
        registros = registroRepo.cargar()
    }

    // MARK: — Consultas del día

    func ocurrenciasHoy(_ habito: Habito) -> Int {
        let cal = Calendar.current
        return registros.filter {
            $0.origen == .habito &&
            $0.concepto == habito.nombre &&
            cal.isDateInToday($0.fecha)
        }.count
    }

    func puntosHoy(_ habito: Habito) -> Int {
        let cal = Calendar.current
        return registros.filter {
            ($0.origen == .habito || $0.origen == .bonusStreak) &&
            $0.concepto.contains(habito.nombre) &&
            cal.isDateInToday($0.fecha)
        }.reduce(0) { $0 + $1.cantidad }
    }

    // MARK: — Reset de rachas

    func recargar() {
        habitos = habitoRepo.cargar()
        registros = registroRepo.cargar()
        resetearRachasRotas()
    }

    func resetearRachasRotas() {
        habitos = registrarUseCase.resetearRachasRotas(habitos: habitos)
    }
}
