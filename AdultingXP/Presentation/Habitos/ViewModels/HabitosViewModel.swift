import Foundation
import Observation

@Observable
final class HabitosViewModel {

    private let habitoRepo: any HabitoRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

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
        guard let index = habitos.firstIndex(where: { $0.id == habito.id }) else { return }

        let nuevoStreak = calcularNuevoStreak(para: habito)
        habitos[index].streakActual = nuevoStreak
        habitos[index].fechaUltimaCompletacion = .now
        habitoRepo.guardar(habitos)

        let delta = habito.esBueno ? habito.puntajeBase : -habito.puntajeBase
        registros.append(RegistroPuntos(cantidad: delta, concepto: habito.nombre, origen: .habito))

        if let bonus = bonusPorStreak(nuevoStreak, puntajeBase: habito.puntajeBase) {
            registros.append(RegistroPuntos(
                cantidad: bonus,
                concepto: "🔥 Racha de \(nuevoStreak) · \(habito.nombre)",
                origen: .bonusStreak
            ))
        }

        registroRepo.guardar(registros)
    }

    // MARK: — Reset de rachas

    /// Revisa todos los hábitos y pone streakActual = 0 en los que se rompieron.
    /// Llamar al inicializar y cada vez que la vista aparece (puede haber pasado la medianoche).
    func resetearRachasRotas() {
        var huboResets = false
        for index in habitos.indices where habitos[index].streakActual > 0 {
            if streakRoto(habitos[index]) {
                habitos[index].streakActual = 0
                huboResets = true
            }
        }
        if huboResets { habitoRepo.guardar(habitos) }
    }

    // MARK: — Consultas

    func estaCompletadoHoy(_ habito: Habito) -> Bool {
        guard let fecha = habito.fechaUltimaCompletacion else { return false }
        return Calendar.current.isDateInToday(fecha)
    }

    // MARK: — Streak (se moverá a CompletarHabitoUseCase en CH-2.1)

    private func streakRoto(_ habito: Habito) -> Bool {
        guard let ultima = habito.fechaUltimaCompletacion else { return false }
        let calendar = Calendar.current

        switch habito.frecuencia {
        case .diario:
            return !calendar.isDateInToday(ultima) && !calendar.isDateInYesterday(ultima)

        case .semanal:
            var cal = Calendar.current
            cal.firstWeekday = UserSettings.diaCorteSemanal
            let inicioPeriodoActual = inicioPeriodoSemanal(para: .now, calendar: cal)
            // Si la última completación es anterior al inicio del período pasado, la racha se rompió
            guard let inicioPeriodoAnterior = cal.date(byAdding: .weekOfYear, value: -1, to: inicioPeriodoActual) else {
                return false
            }
            return ultima < inicioPeriodoAnterior
        }
    }

    private func calcularNuevoStreak(para habito: Habito) -> Int {
        guard let ultima = habito.fechaUltimaCompletacion else { return 1 }
        let calendar = Calendar.current

        switch habito.frecuencia {
        case .diario:
            if calendar.isDateInYesterday(ultima)  { return habito.streakActual + 1 }
            if calendar.isDateInToday(ultima)       { return habito.streakActual }
            return 1

        case .semanal:
            var cal = Calendar.current
            cal.firstWeekday = UserSettings.diaCorteSemanal
            let inicioPeriodoActual = inicioPeriodoSemanal(para: .now, calendar: cal)
            guard let inicioPeriodoAnterior = cal.date(byAdding: .weekOfYear, value: -1, to: inicioPeriodoActual) else {
                return 1
            }
            if ultima >= inicioPeriodoActual   { return habito.streakActual }       // ya completado este período
            if ultima >= inicioPeriodoAnterior { return habito.streakActual + 1 }   // período anterior, continúa
            return 1
        }
    }

    private func inicioPeriodoSemanal(para fecha: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: fecha)
        return calendar.date(from: components) ?? fecha
    }

    private func bonusPorStreak(_ streak: Int, puntajeBase: Int) -> Int? {
        switch streak {
        case 3:  return max(1, puntajeBase / 2)
        case 7:  return puntajeBase
        case 14: return puntajeBase * 2
        case 30: return puntajeBase * 3
        default: return nil
        }
    }
}
