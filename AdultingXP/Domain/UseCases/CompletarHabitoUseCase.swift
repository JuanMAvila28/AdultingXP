import Foundation

// Nota: el archivo conserva su nombre por compatibilidad con el proyecto Xcode.
// El struct se renombró a RegistrarOcurrenciaHabitoUseCase para reflejar
// que registra una ocurrencia (puede usarse varias veces al día), no una completación única.

struct RegistrarOcurrenciaHabitoUseCase {
    private let habitoRepo: any HabitoRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

    init(
        habitoRepo: any HabitoRepositoryProtocol,
        registroRepo: any RegistroPuntosRepositoryProtocol
    ) {
        self.habitoRepo = habitoRepo
        self.registroRepo = registroRepo
    }

    // MARK: — Registrar ocurrencia

    struct Resultado {
        let habitoActualizado: Habito
        let nuevosRegistros: [RegistroPuntos]
    }

    func ejecutar(
        habito: Habito,
        todosLosHabitos: [Habito],
        registrosActuales: [RegistroPuntos]
    ) -> Resultado {
        var actualizado = habito
        let nuevoStreak = calcularNuevoStreak(para: habito)
        actualizado.streakActual = nuevoStreak
        // Reinterpretado como "fecha del último registro de ocurrencia" (antes: "fecha de completación única")
        actualizado.fechaUltimaCompletacion = .now

        var habitosActualizados = todosLosHabitos
        if let i = habitosActualizados.firstIndex(where: { $0.id == habito.id }) {
            habitosActualizados[i] = actualizado
        }
        habitoRepo.guardar(habitosActualizados)

        let delta = habito.esBueno ? habito.puntajeBase : -habito.puntajeBase
        var nuevos: [RegistroPuntos] = [
            RegistroPuntos(cantidad: delta, concepto: habito.nombre, origen: .habito)
        ]
        // El bonus de racha solo se genera cuando el streak sube (primer toque del día que extiende racha)
        if let bonus = bonusPorStreak(nuevoStreak, puntajeBase: habito.puntajeBase),
           nuevoStreak != habito.streakActual {
            nuevos.append(RegistroPuntos(
                cantidad: bonus,
                concepto: "🔥 Racha de \(nuevoStreak) · \(habito.nombre)",
                origen: .bonusStreak
            ))
        }
        registroRepo.guardar(registrosActuales + nuevos)

        return Resultado(habitoActualizado: actualizado, nuevosRegistros: nuevos)
    }

    // MARK: — Deshacer última ocurrencia

    struct ResultadoDeshacer {
        let habitoRestaurado: Habito
    }

    /// Elimina el registro con `registroId` y restaura el hábito a su estado previo al toque.
    /// También elimina cualquier bonus de racha generado hoy para este hábito (mismo toque).
    @discardableResult
    func deshacerConRegistro(
        habitoAntes: Habito,
        registroId: UUID,
        todosLosHabitos: [Habito],
        registrosActuales: [RegistroPuntos]
    ) -> ResultadoDeshacer {
        let cal = Calendar.current
        var registros = registrosActuales

        // Quitar la ocurrencia específica
        registros.removeAll { $0.id == registroId }

        // Quitar bonus de racha de hoy para este hábito (si lo hubo en el mismo toque)
        registros.removeAll {
            $0.origen == .bonusStreak &&
            $0.concepto.contains(habitoAntes.nombre) &&
            cal.isDateInToday($0.fecha)
        }

        // Restaurar el hábito a su estado exacto previo al toque
        var habitos = todosLosHabitos
        if let i = habitos.firstIndex(where: { $0.id == habitoAntes.id }) {
            habitos[i] = habitoAntes
        }

        habitoRepo.guardar(habitos)
        registroRepo.guardar(registros)

        return ResultadoDeshacer(habitoRestaurado: habitoAntes)
    }

    // MARK: — Reset de rachas rotas

    func resetearRachasRotas(habitos: [Habito]) -> [Habito] {
        var actualizado = habitos
        var huboResets = false
        for i in actualizado.indices where actualizado[i].streakActual > 0 {
            if streakRoto(actualizado[i]) {
                actualizado[i].streakActual = 0
                huboResets = true
            }
        }
        if huboResets { habitoRepo.guardar(actualizado) }
        return actualizado
    }

    // MARK: — Lógica de streak (privada)

    private func calcularNuevoStreak(para habito: Habito) -> Int {
        guard let ultima = habito.fechaUltimaCompletacion else { return 1 }
        let calendar = Calendar.current

        switch habito.frecuencia {
        case .diario:
            if calendar.isDateInYesterday(ultima) { return habito.streakActual + 1 }
            if calendar.isDateInToday(ultima)     { return habito.streakActual }
            return 1

        case .semanal:
            var cal = Calendar.current
            cal.firstWeekday = UserSettings.diaCorteSemanal
            let inicioPeriodoActual = inicioPeriodoSemanal(para: .now, calendar: cal)
            guard let inicioPeriodoAnterior = cal.date(byAdding: .weekOfYear, value: -1, to: inicioPeriodoActual) else {
                return 1
            }
            if ultima >= inicioPeriodoActual   { return habito.streakActual }
            if ultima >= inicioPeriodoAnterior { return habito.streakActual + 1 }
            return 1
        }
    }

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
            guard let inicioPeriodoAnterior = cal.date(byAdding: .weekOfYear, value: -1, to: inicioPeriodoActual) else {
                return false
            }
            return ultima < inicioPeriodoAnterior
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
