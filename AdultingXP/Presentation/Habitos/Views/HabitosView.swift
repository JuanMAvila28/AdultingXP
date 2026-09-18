import SwiftUI

struct HabitosView: View {
    @State private var viewModel = HabitosViewModel()
    @State private var mostrandoCrear = false
    @State private var habitoAEditar: Habito? = nil
    @State private var habitoAEliminar: Habito? = nil
    @State private var mostrandoConfirmacion = false
    @State private var habitoSeleccionado: Habito? = nil

    // Undo
    private struct EstadoUndo: Equatable {
        static func == (lhs: EstadoUndo, rhs: EstadoUndo) -> Bool { lhs.registroId == rhs.registroId }
        let habitoAntes: Habito
        let registroId: UUID
    }
    @State private var estadoUndo: EstadoUndo? = nil
    @State private var tareaToast: Task<Void, Never>? = nil

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
                        Button {
                            habitoSeleccionado = habito
                        } label: {
                            HabitoRow(
                                habito: habito,
                                ocurrenciasHoy: viewModel.ocurrenciasHoy(habito),
                                puntosHoy: viewModel.puntosHoy(habito),
                                onRegistrar: {
                                    registrarConUndo(habito)
                                }
                            )
                        }
                        .buttonStyle(.plain)
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
        .navigationDestination(item: $habitoSeleccionado) { habito in
            HabitoDetailView(habito: habito, registros: viewModel.registros)
        }
        .animation(AppAnimation.standard, value: viewModel.filtroCategoria)
        .overlay(alignment: .bottom) {
            if let undo = estadoUndo {
                ToastDeshacer(nombre: undo.habitoAntes.nombre) {
                    tareaToast?.cancel()
                    viewModel.deshacer(habitoAntes: undo.habitoAntes, registroId: undo.registroId)
                    estadoUndo = nil
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 72)
            }
        }
        .animation(AppAnimation.bouncy, value: estadoUndo != nil)
    }

    // MARK: — Undo

    private func registrarConUndo(_ habito: Habito) {
        let habitoAntes = habito  // captura estado antes de que el ViewModel lo mute
        guard let regId = viewModel.registrar(habito) else { return }

        tareaToast?.cancel()
        estadoUndo = EstadoUndo(habitoAntes: habitoAntes, registroId: regId)
        tareaToast = Task {
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run { estadoUndo = nil }
        }
    }

    // MARK: — Filtros

    private var filtroChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                FiltroChip(titulo: "Todos", seleccionado: viewModel.filtroCategoria == nil) {
                    viewModel.filtroCategoria = nil
                }
                ForEach(viewModel.categorias, id: \.self) { cat in
                    FiltroChip(titulo: cat, seleccionado: viewModel.filtroCategoria == cat) {
                        viewModel.filtroCategoria = cat
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
    }
}

// MARK: — Balance

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
    let ocurrenciasHoy: Int
    let puntosHoy: Int
    let onRegistrar: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric private var emojiFrame: CGFloat = 36
    @State private var escala: CGFloat = 1.0

    private var colorBoton: Color {
        habito.esBueno ? .appPositive : .appWarning
    }

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

                if ocurrenciasHoy > 0 {
                    HStack(spacing: Spacing.xs) {
                        Text("×\(ocurrenciasHoy) hoy")
                        Text("·")
                        Text("\(puntosHoy >= 0 ? "+" : "")\(puntosHoy) pts")
                            .foregroundStyle(puntosHoy >= 0 ? Color.appPositive : Color.appNegative)
                    }
                    .font(.appCaption)
                    .contentTransition(.numericText())
                    .animation(AppAnimation.standard, value: ocurrenciasHoy)
                }
            }

            Spacer()

            Button {
                onRegistrar()
                if !reduceMotion {
                    escala = 1.35
                    withAnimation(AppAnimation.bouncy) { escala = 1.0 }
                }
            } label: {
                Image(systemName: ocurrenciasHoy > 0 ? "plus.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundStyle(colorBoton)
                    .scaleEffect(escala)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.success, trigger: ocurrenciasHoy)
            .accessibilityLabel("Registrar \(habito.nombre)")
            .accessibilityHint("\(habito.esBueno ? "Suma" : "Resta") \(habito.puntajeBase) puntos")
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Toast de deshacer

private struct ToastDeshacer: View {
    let nombre: String
    let onDeshacer: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text("«\(nombre)» registrado")
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            Button("Deshacer", action: onDeshacer)
                .font(.subheadline.bold())
                .tint(.appAccent)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm + 2)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: — Preview

#Preview {
    HabitosView()
}
