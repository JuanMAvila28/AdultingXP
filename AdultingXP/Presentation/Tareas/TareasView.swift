import SwiftUI

struct TareasView: View {
    @State private var viewModel = TareasViewModel()
    @State private var mostrandoCrear = false
    @State private var tareaAEliminar: Tarea? = nil
    @State private var mostrandoConfirmacion = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.tareas.isEmpty {
                    ContentUnavailableView(
                        "Sin tareas",
                        systemImage: "graduationcap",
                        description: Text("Toca + para agregar tu primera tarea")
                    )
                } else {
                    listaTareas
                }
            }
            .navigationTitle("Tareas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Agregar", systemImage: "plus") {
                        mostrandoCrear = true
                    }
                }
            }
            .sheet(isPresented: $mostrandoCrear) {
                CrearTareaView { tarea in
                    viewModel.agregar(tarea)
                }
            }
            .confirmationDialog(
                "Eliminar «\(tareaAEliminar?.titulo ?? "")»",
                isPresented: $mostrandoConfirmacion,
                titleVisibility: .visible
            ) {
                Button("Eliminar", role: .destructive) {
                    if let t = tareaAEliminar { viewModel.eliminar(t) }
                    tareaAEliminar = nil
                }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }

    // MARK: — Lista

    private var listaTareas: some View {
        List {
            Section {
                BalanceTareasRow(balance: viewModel.balanceGlobal)
            }

            if !viewModel.tareasPendientes.isEmpty {
                Section("Pendientes") {
                    ForEach(viewModel.tareasPendientes) { tarea in
                        TareaPendienteRow(tarea: tarea, onCompletar: { viewModel.completar(tarea) })
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    tareaAEliminar = tarea
                                    mostrandoConfirmacion = true
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                    }
                }
            }

            if !viewModel.tareasCompletadas.isEmpty {
                Section("Completadas") {
                    ForEach(viewModel.tareasCompletadas) { tarea in
                        TareaCompletadaRow(tarea: tarea)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: — Balance

private struct BalanceTareasRow: View {
    let balance: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Balance disponible")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                Text("\(balance >= 0 ? "+" : "")\(balance) pts")
                    .font(.appPoints)
                    .foregroundStyle(balance >= 0 ? Color.appPositive : Color.appNegative)
                    .contentTransition(.numericText())
                    .animation(AppAnimation.standard, value: balance)
            }
            Spacer()
            Image(systemName: "graduationcap.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.appAccent)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Fila pendiente

private struct TareaPendienteRow: View {
    let tarea: Tarea
    let onCompletar: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var escala: CGFloat = 1.0

    private var urgencyColor: Color {
        if tarea.estaVencida { return .appNegative }
        if tarea.fechaLimite.timeIntervalSinceNow < 86_400 { return .appWarning }
        return .secondary
    }

    private var urgencyIcon: String {
        if tarea.estaVencida { return "exclamationmark.circle.fill" }
        if tarea.fechaLimite.timeIntervalSinceNow < 86_400 { return "clock.fill" }
        return "clock"
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(tarea.titulo)
                    .font(.appHeadline)

                HStack(spacing: Spacing.xs) {
                    Text(tarea.materia)
                    Text("·")
                    Image(systemName: urgencyIcon)
                    Text(tarea.fechaLimite, style: .relative)
                    Text("·")
                    Text("±\(tarea.puntajeBase) pts")
                }
                .font(.appCaption)
                .foregroundStyle(urgencyColor)
            }

            Spacer()

            Button {
                onCompletar()
                if !reduceMotion {
                    escala = 1.3
                    withAnimation(AppAnimation.bouncy) { escala = 1.0 }
                }
            } label: {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(urgencyColor)
                    .scaleEffect(escala)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.success, trigger: tarea.completada)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Fila completada

private struct TareaCompletadaRow: View {
    let tarea: Tarea

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(tarea.titulo)
                    .font(.appHeadline)
                    .strikethrough()
                    .foregroundStyle(.secondary)

                Text(tarea.materia)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let aTiempo = tarea.fueCompletadaATiempo {
                Text(aTiempo ? "+\(tarea.puntajeBase) pts" : "−\(tarea.puntajeBase) pts")
                    .font(.appCaption)
                    .foregroundStyle(aTiempo ? Color.appPositive : Color.appNegative)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    TareasView()
}
