import SwiftUI

struct HabitosView: View {
    @State private var viewModel = HabitosViewModel()
    @State private var mostrandoCrear = false

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
                    List(viewModel.habitos) { habito in
                        HabitoRow(habito: habito)
                    }
                    .listStyle(.insetGrouped)
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
        }
    }
}

// MARK: — Fila

private struct HabitoRow: View {
    let habito: Habito

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(habito.emoji)
                .font(.title2)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(habito.nombre)
                    .font(.appHeadline)

                Text("\(habito.categoria) · \(habito.frecuencia.label)")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(habito.esBueno ? "+" : "−")\(habito.puntajeBase) pts")
                .font(.appCaption)
                .fontWeight(.semibold)
                .foregroundStyle(habito.esBueno ? Color.appPositive : Color.appNegative)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    HabitosView()
}
