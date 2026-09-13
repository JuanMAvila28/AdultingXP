import SwiftUI

struct HistorialView: View {
    @State private var registros: [RegistroPuntos] = []
    @State private var filtroOrigen: OrigenPuntos? = nil

    private var balance: Int {
        registros.reduce(0) { $0 + $1.cantidad }
    }

    private var registrosFiltrados: [RegistroPuntos] {
        let fuente = filtroOrigen.map { f in registros.filter { $0.origen == f } } ?? registros
        return fuente.sorted { $0.fecha > $1.fecha }
    }

    var body: some View {
        List {
            Section {
                BalanceHistorialRow(balance: balance)
            }

            if !registros.isEmpty {
                Section {
                    filtroChips
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
            }

            Section {
                if registrosFiltrados.isEmpty {
                    Text("Sin registros para este filtro")
                        .foregroundStyle(.secondary)
                        .font(.appBody)
                } else {
                    ForEach(registrosFiltrados) { registro in
                        RegistroRow(registro: registro)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { registros = RegistroPuntosRepository().cargar() }
        .animation(AppAnimation.standard, value: filtroOrigen)
    }

    private var filtroChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                FiltroChip(titulo: "Todos", seleccionado: filtroOrigen == nil) {
                    filtroOrigen = nil
                }
                ForEach(OrigenPuntos.allCases, id: \.self) { origen in
                    FiltroChip(titulo: origen.label, seleccionado: filtroOrigen == origen) {
                        filtroOrigen = origen
                    }
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
