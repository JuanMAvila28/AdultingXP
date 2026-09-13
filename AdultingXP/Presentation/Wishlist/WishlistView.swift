import SwiftUI

struct WishlistView: View {
    @State private var viewModel = WishlistViewModel()
    @State private var mostrandoCrear = false
    @State private var itemAEliminar: ItemWishlist? = nil
    @State private var mostrandoConfirmacion = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "Sin recompensas",
                        systemImage: "gift",
                        description: Text("Toca + para agregar tu primera recompensa")
                    )
                } else {
                    listaItems
                }
            }
            .navigationTitle("Wishlist")
            .onAppear { viewModel.recargarRegistros() }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Agregar", systemImage: "plus") {
                        mostrandoCrear = true
                    }
                }
            }
            .sheet(isPresented: $mostrandoCrear) {
                CrearItemWishlistView { item in
                    viewModel.agregar(item)
                }
            }
            .confirmationDialog(
                "Eliminar «\(itemAEliminar?.nombre ?? "")»",
                isPresented: $mostrandoConfirmacion,
                titleVisibility: .visible
            ) {
                Button("Eliminar", role: .destructive) {
                    if let item = itemAEliminar { viewModel.eliminar(item) }
                    itemAEliminar = nil
                }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }

    // MARK: — Lista

    private var listaItems: some View {
        List {
            Section {
                BalanceWishlistRow(balance: viewModel.balanceGlobal)
            }

            if !viewModel.itemsPendientes.isEmpty {
                Section("Mis recompensas") {
                    ForEach(viewModel.itemsPendientes) { item in
                        ItemWishlistRow(
                            item: item,
                            progreso: viewModel.progreso(para: item),
                            puedeReclamar: viewModel.puedeReclamar(item),
                            onReclamar: { viewModel.reclamar(item) }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                itemAEliminar = item
                                mostrandoConfirmacion = true
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            if !viewModel.itemsReclamados.isEmpty {
                Section("Reclamados") {
                    ForEach(viewModel.itemsReclamados) { item in
                        ItemWishlistRow(item: item, progreso: 1.0, puedeReclamar: false)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: — Balance

private struct BalanceWishlistRow: View {
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
            Image(systemName: "star.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.appAccent)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Fila de ítem

private struct ItemWishlistRow: View {
    let item: ItemWishlist
    let progreso: Double
    let puedeReclamar: Bool
    var onReclamar: (() -> Void)? = nil

    @ScaledMetric private var emojiFrame: CGFloat = 36

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.md) {
                Text(item.emoji)
                    .font(.title2)
                    .frame(width: emojiFrame)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(item.nombre)
                        .font(.appHeadline)
                        .strikethrough(item.reclamado)

                    Text("\(item.costoEnPuntos) pts")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if item.reclamado {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appPositive)
                } else if puedeReclamar {
                    Button(action: { onReclamar?() }) {
                        Image(systemName: "gift.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appAccent)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.success, trigger: item.reclamado)
                }
            }

            if !item.reclamado {
                ProgressView(value: progreso)
                    .tint(puedeReclamar ? Color.appPositive : Color.appAccent)
                    .animation(AppAnimation.standard, value: progreso)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    WishlistView()
}
