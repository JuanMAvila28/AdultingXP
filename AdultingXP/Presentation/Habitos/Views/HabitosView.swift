import SwiftUI

struct HabitosView: View {
    @State private var viewModel = HabitosViewModel()
    @State private var mostrandoCrear = false
    @State private var habitoAEditar: Habito? = nil
    @State private var habitoAEliminar: Habito? = nil
    @State private var mostrandoConfirmacion = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.habitos.isEmpty {
                    ContentUnavailableView(
                        "Sin hábitos",
                        systemImage: "checkmark.circle",
                        description: Text("Toca + para agregar tu primer hábito")
                    )
                } else {
                    listaHabitos
                }
            }
            .navigationTitle("Hábitos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Agregar", systemImage: "plus") {
                        mostrandoCrear = true
                    }
                }
            }
            .sheet(isPresented: $mostrandoCrear) {
                CrearHabitoView { habito in
                    viewModel.agregar(habito)
                }
            }
            .sheet(item: $habitoAEditar) { habito in
                EditarHabitoView(habito: habito) { actualizado in
                    viewModel.actualizar(actualizado)
                }
            }
            .confirmationDialog(
                "Eliminar «\(habitoAEliminar?.nombre ?? "")»",
                isPresented: $mostrandoConfirmacion,
                titleVisibility: .visible
            ) {
                Button("Eliminar", role: .destructive) {
                    if let h = habitoAEliminar { viewModel.eliminar(h) }
                    habitoAEliminar = nil
                }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }

    // MARK: — Lista

    private var listaHabitos: some View {
        List {
            Section {
                BalanceRow(balance: viewModel.balanceGlobal)
            }
            Section("Mis hábitos") {
                ForEach(viewModel.habitos) { habito in
                    HabitoRow(
                        habito: habito,
                        completadoHoy: viewModel.estaCompletadoHoy(habito),
                        onCompletar: { viewModel.completar(habito) }
                    )
                    .swipeActions(edge: .leading) {
                        Button {
                            habitoAEditar = habito
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            habitoAEliminar = habito
                            mostrandoConfirmacion = true
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: — Tarjeta de balance

private struct BalanceRow: View {
    let balance: Int

    private var color: Color {
        if balance > 0 { return .appPositive }
        if balance < 0 { return .appNegative }
        return .secondary
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Balance global")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                Text("\(balance >= 0 ? "+" : "")\(balance) pts")
                    .font(.appPoints)
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
                    .animation(AppAnimation.standard, value: balance)
            }
            Spacer()
            Image(systemName: balance >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(color)
                .animation(AppAnimation.standard, value: balance)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Fila de hábito

private struct HabitoRow: View {
    let habito: Habito
    let completadoHoy: Bool
    let onCompletar: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(habito.emoji)
                .font(.title2)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(habito.nombre)
                    .font(.appHeadline)

                Text("\(habito.categoria) · \(habito.frecuencia.label) · \(habito.esBueno ? "+" : "−")\(habito.puntajeBase) pts")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onCompletar) {
                Image(systemName: completadoHoy
                      ? "checkmark.circle.fill"
                      : (habito.esBueno ? "checkmark.circle" : "minus.circle"))
                    .font(.title2)
                    .foregroundStyle(completadoHoy
                                     ? Color.secondary
                                     : (habito.esBueno ? Color.appPositive : Color.appNegative))
                    .animation(AppAnimation.standard, value: completadoHoy)
            }
            .buttonStyle(.plain)
            .disabled(completadoHoy)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    HabitosView()
}
