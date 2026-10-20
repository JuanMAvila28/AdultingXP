import SwiftUI

struct OrdenarHabitosView: View {
    let viewModel: HabitosViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if viewModel.ordenesCategorias.count > 1 {
                    Section {
                        ForEach(viewModel.ordenesCategorias, id: \.self) { cat in
                            Label(cat, systemImage: "folder.fill")
                                .foregroundStyle(.primary)
                        }
                        .onMove { from, to in
                            viewModel.moverCategoria(from: from, to: to)
                        }
                    } header: {
                        Text("Categorías")
                    } footer: {
                        Text("Arrastra para cambiar el orden de las secciones.")
                    }
                }

                ForEach(viewModel.habitosAgrupados, id: \.categoria) { grupo in
                    Section(grupo.categoria) {
                        ForEach(grupo.items) { habito in
                            HStack(spacing: Spacing.sm) {
                                Text(habito.emoji)
                                    .font(.title3)
                                Text(habito.nombre)
                                    .font(.appHeadline)
                            }
                        }
                        .onMove { from, to in
                            viewModel.moverHabito(enCategoria: grupo.categoria, from: from, to: to)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Ordenar hábitos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    OrdenarHabitosView(viewModel: HabitosViewModel())
}
