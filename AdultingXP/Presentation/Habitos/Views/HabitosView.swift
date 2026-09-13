import SwiftUI

struct HabitosView: View {
    @State private var viewModel = HabitosViewModel()
    @State private var mostrandoCrear = false
    @State private var mostrandoSettings = false
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
            .onAppear { viewModel.recargar() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Configuración", systemImage: "gearshape") {
                        mostrandoSettings = true
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Agregar", systemImage: "plus") {
                        mostrandoCrear = true
                    }
                }
            }
            .sheet(isPresented: $mostrandoSettings) {
                HabitosSettingsView()
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
                NavigationLink {
                    HistorialView()
                } label: {
                    BalanceRow(balance: viewModel.balanceGlobal)
                }
            }

            if viewModel.categorias.count > 1 {
                Section {
                    filtroChips
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
            }

            ForEach(viewModel.habitosAgrupados, id: \.categoria) { grupo in
                Section(grupo.categoria) {
                    ForEach(grupo.items) { habito in
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
        }
        .listStyle(.insetGrouped)
        .animation(AppAnimation.standard, value: viewModel.filtroCategoria)
    }

    private var filtroChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                CategoriaChip(
                    titulo: "Todos",
                    seleccionado: viewModel.filtroCategoria == nil
                ) {
                    viewModel.filtroCategoria = nil
                }
                ForEach(viewModel.categorias, id: \.self) { cat in
                    CategoriaChip(
                        titulo: cat,
                        seleccionado: viewModel.filtroCategoria == cat
                    ) {
                        viewModel.filtroCategoria = cat
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
    }
}

// MARK: — Chip de categoría

private struct CategoriaChip: View {
    let titulo: String
    let seleccionado: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(titulo)
                .font(.appCaption)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(seleccionado ? Color.appAccent : Color.secondary.opacity(0.12))
                .foregroundStyle(seleccionado ? Color.white : Color.primary)
                .clipShape(Capsule())
                .animation(AppAnimation.quick, value: seleccionado)
        }
        .buttonStyle(.plain)
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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric private var emojiFrame: CGFloat = 36
    @State private var escala: CGFloat = 1.0

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(habito.emoji)
                .font(.title2)
                .frame(width: emojiFrame)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(habito.nombre)
                    .font(.appHeadline)

                HStack(spacing: Spacing.xs) {
                    Text("\(habito.categoria) · \(habito.frecuencia.label) · \(habito.esBueno ? "+" : "−")\(habito.puntajeBase) pts")

                    if habito.streakActual > 0 {
                        Text("· 🔥\(habito.streakActual)")
                    }
                }
                .font(.appCaption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                guard !completadoHoy else { return }
                onCompletar()
                if !reduceMotion {
                    escala = 1.3
                    withAnimation(AppAnimation.bouncy) { escala = 1.0 }
                }
            } label: {
                Image(systemName: completadoHoy
                      ? "checkmark.circle.fill"
                      : (habito.esBueno ? "checkmark.circle" : "minus.circle"))
                    .font(.title2)
                    .foregroundStyle(completadoHoy
                                     ? Color.secondary
                                     : (habito.esBueno ? Color.appPositive : Color.appNegative))
                    .scaleEffect(escala)
                    .animation(AppAnimation.standard, value: completadoHoy)
            }
            .buttonStyle(.plain)
            .disabled(completadoHoy)
            .sensoryFeedback(.success, trigger: completadoHoy)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    HabitosView()
}
