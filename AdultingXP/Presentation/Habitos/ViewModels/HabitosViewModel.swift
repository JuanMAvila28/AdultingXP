import Foundation
import Observation

@Observable
final class HabitosViewModel {

    private let habitoRepo: any HabitoRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol
    private let registrarUseCase: RegistrarOcurrenciaHabitoUseCase
    private let ordenCatFilename = "ordenes_categorias.json"

    var habitos: [Habito] = []
    var registros: [RegistroPuntos] = []
    var filtroCategoria: String? = nil
    var ordenesCategorias: [String] = []

    var balanceGlobal: Int {
        registros.reduce(0) { $0 + $1.cantidad }
    }

    var categorias: [String] {
        let todas = Set(habitos.map(\.categoria))
        let conocidas = ordenesCategorias.filter { todas.contains($0) }
        let nuevas = todas.subtracting(Set(ordenesCategorias)).sorted()
        return conocidas + Array(nuevas)
    }

    var habitosAgrupados: [(categoria: String, items: [Habito])] {
        let fuente = filtroCategoria.map { f in habitos.filter { $0.categoria == f } } ?? habitos
        let agrupados = Dictionary(grouping: fuente, by: \.categoria)
        let catOrdenadas: [String] = {
            let conocidas = ordenesCategorias.filter { agrupados[$0] != nil }
            let nuevas = agrupados.keys.filter { !ordenesCategorias.contains($0) }.sorted()
            return conocidas + nuevas
        }()
        return catOrdenadas.compactMap { cat in
            guard let items = agrupados[cat] else { return nil }
            return (categoria: cat, items: items.sorted { $0.orden < $1.orden })
        }
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
        cargarOrdenesCategorias()
        resetearRachasRotas()
    }

    // MARK: — Acciones

    func agregar(_ habito: Habito) {
        var nuevo = habito
        let maxOrden = habitos.filter { $0.categoria == habito.categoria }.map(\.orden).max() ?? -1
        nuevo.orden = maxOrden + 1
        habitos.append(nuevo)
        habitoRepo.guardar(habitos)
        if !ordenesCategorias.contains(habito.categoria) {
            ordenesCategorias.append(habito.categoria)
            guardarOrdenesCategorias()
        }
    }

    func actualizar(_ habito: Habito) {
        guard let index = habitos.firstIndex(where: { $0.id == habito.id }) else { return }
        let categoriaAntes = habitos[index].categoria
        habitos[index] = habito
        habitoRepo.guardar(habitos)
        if categoriaAntes != habito.categoria {
            if !ordenesCategorias.contains(habito.categoria) {
                ordenesCategorias.append(habito.categoria)
            }
            if habitos.filter({ $0.categoria == categoriaAntes }).isEmpty {
                ordenesCategorias.removeAll { $0 == categoriaAntes }
            }
            guardarOrdenesCategorias()
        }
    }

    func eliminar(_ habito: Habito) {
        let categoria = habito.categoria
        habitos.removeAll { $0.id == habito.id }
        habitoRepo.guardar(habitos)
        if habitos.filter({ $0.categoria == categoria }).isEmpty {
            ordenesCategorias.removeAll { $0 == categoria }
            guardarOrdenesCategorias()
        }
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

    // MARK: — Ordenamiento

    func moverCategoria(from: IndexSet, to: Int) {
        ordenesCategorias.move(fromOffsets: from, toOffset: to)
        guardarOrdenesCategorias()
    }

    func moverHabito(enCategoria categoria: String, from: IndexSet, to: Int) {
        var items = habitos
            .filter { $0.categoria == categoria }
            .sorted { $0.orden < $1.orden }
        items.move(fromOffsets: from, toOffset: to)
        for (nuevoOrden, item) in items.enumerated() {
            if let i = habitos.firstIndex(where: { $0.id == item.id }) {
                habitos[i].orden = nuevoOrden
            }
        }
        habitoRepo.guardar(habitos)
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

    // MARK: — Privado

    private func cargarOrdenesCategorias() {
        let guardadas = JSONStore.load([String].self, fromFile: ordenCatFilename) ?? []
        let todas = Set(habitos.map(\.categoria))
        let conocidas = guardadas.filter { todas.contains($0) }
        let nuevas = todas.subtracting(Set(guardadas)).sorted()
        ordenesCategorias = conocidas + Array(nuevas)
    }

    private func guardarOrdenesCategorias() {
        JSONStore.save(ordenesCategorias, toFile: ordenCatFilename)
    }
}
