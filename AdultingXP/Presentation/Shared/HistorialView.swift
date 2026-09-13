import SwiftUI

private enum PeriodoHistorial: CaseIterable {
    case todo, semana, mes

    var label: String {
        switch self {
        case .todo:   return "Todo"
        case .semana: return "Esta semana"
        case .mes:    return "Este mes"
        }
    }

    var inicio: Date? {
        let cal = Calendar.current
        switch self {
        case .todo:   return nil
        case .semana: return cal.dateInterval(of: .weekOfYear, for: .now)?.start
        case .mes:    return cal.dateInterval(of: .month,       for: .now)?.start
        }
    }
}

struct HistorialView: View {
    @State private var registros: [RegistroPuntos] = []
    @State private var filtroOrigen: OrigenPuntos? = nil
    @State private var filtroPeriodo: PeriodoHistorial = .todo
    @State private var busqueda = ""

    private var balance: Int {
        registros.reduce(0) { $0 + $1.cantidad }
    }

    private var registrosFiltrados: [RegistroPuntos] {
        var fuente = filtroOrigen.map { f in registros.filter { $0.origen == f } } ?? registros
        if let inicio = filtroPeriodo.inicio {
            fuente = fuente.filter { $0.fecha >= inicio }
        }
        if !busqueda.isEmpty {
            fuente = fuente.filter { $0.concepto.localizedCaseInsensitiveContains(busqueda) }
        }
        return fuente.sorted { $0.fecha > $1.fecha }
    }

    private var registrosPorFecha: [(dia: Date, items: [RegistroPuntos])] {
        let cal = Calendar.current
        let agrupados = Dictionary(grouping: registrosFiltrados) { cal.startOfDay(for: $0.fecha) }
        return agrupados.map { (dia: $0.key, items: $0.value) }
                        .sorted { $0.dia > $1.dia }
    }

    var body: some View {
        List {
            Section {
                BalanceHistorialRow(balance: balance)
            }

            if !registros.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        chipRow(
                            chips: [("Todos", filtroOrigen == nil, { filtroOrigen = nil })] +
                                OrigenPuntos.allCases.map { o in
                                    (o.label, filtroOrigen == o, { filtroOrigen = o })
                                }
                        )
                        Divider().padding(.leading, Spacing.md)
                        chipRow(
                            chips: PeriodoHistorial.allCases.map { p in
                                (p.label, filtroPeriodo == p, { filtroPeriodo = p })
                            }
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
            }

            if registrosPorFecha.isEmpty {
                Section {
                    Text("Sin registros para este filtro")
                        .foregroundStyle(.secondary)
                        .font(.appBody)
                }
            } else {
                ForEach(registrosPorFecha, id: \.dia) { grupo in
                    Section(header: Text(grupo.dia.etiquetaDia)) {
                        ForEach(grupo.items) { registro in
                            RegistroRow(registro: registro)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $busqueda, prompt: "Buscar en historial")
        .onAppear { registros = RegistroPuntosRepository().cargar() }
        .animation(AppAnimation.standard, value: filtroOrigen)
        .animation(AppAnimation.standard, value: filtroPeriodo)
        .animation(AppAnimation.standard, value: busqueda)
    }

    private func chipRow(chips: [(String, Bool, () -> Void)]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(chips.indices, id: \.self) { i in
                    let (titulo, seleccionado, accion) = chips[i]
                    FiltroChip(titulo: titulo, seleccionado: seleccionado, onTap: accion)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
    }
}

// MARK: — Balance header

private struct BalanceHistorialRow: View {
    let balance: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Balance global")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                Text("\(balance >= 0 ? "+" : "")\(balance) pts")
                    .font(.appDisplay)
                    .foregroundStyle(balance >= 0 ? Color.appPositive : Color.appNegative)
                    .contentTransition(.numericText())
            }
            Spacer()
            Image(systemName: balance >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(balance >= 0 ? Color.appPositive : Color.appNegative)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Fila de registro

private struct RegistroRow: View {
    let registro: RegistroPuntos

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(registro.concepto)
                    .font(.appBody)
                    .lineLimit(2)

                HStack(spacing: Spacing.xs) {
                    Text(registro.origen.label)
                        .font(.appCaption)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(Capsule())

                    Text(registro.fecha, style: .relative)
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("\(registro.cantidad >= 0 ? "+" : "")\(registro.cantidad) pts")
                .font(.appHeadline)
                .foregroundStyle(registro.cantidad >= 0 ? Color.appPositive : Color.appNegative)
                .monospacedDigit()
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    NavigationStack {
        HistorialView()
    }
}
