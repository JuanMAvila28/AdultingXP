import SwiftUI

struct EditarItemWishlistView: View {
    let item: ItemWishlist
    let onGuardar: (ItemWishlist) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var emoji: String
    @State private var nombre: String
    @State private var descripcion: String
    @State private var costoEnPuntos: Int

    init(item: ItemWishlist, onGuardar: @escaping (ItemWishlist) -> Void) {
        self.item = item
        self.onGuardar = onGuardar
        _emoji = State(initialValue: item.emoji)
        _nombre = State(initialValue: item.nombre)
        _descripcion = State(initialValue: item.descripcion)
        _costoEnPuntos = State(initialValue: item.costoEnPuntos)
    }

    private var formularioValido: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: Spacing.md) {
                        TextField("🎁", text: $emoji)
                            .frame(width: 44)
                            .multilineTextAlignment(.center)
                            .font(.title2)
                        TextField("Nombre de la recompensa", text: $nombre)
                    }
                    TextField("Descripción (opcional)", text: $descripcion)
                }

                Section {
                    Stepper(
                        value: $costoEnPuntos,
                        in: 10...10_000,
                        step: 10
                    ) {
                        Text("**\(costoEnPuntos)** pts")
                    }
                } header: {
                    Text("Costo en puntos")
                }
            }
            .navigationTitle("Editar recompensa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        var actualizado = item
                        actualizado.nombre = nombre.trimmingCharacters(in: .whitespaces)
                        actualizado.emoji = emoji.isEmpty ? "🎁" : String(emoji.prefix(2))
                        actualizado.descripcion = descripcion.trimmingCharacters(in: .whitespaces)
                        actualizado.costoEnPuntos = costoEnPuntos
                        onGuardar(actualizado)
                        dismiss()
                    }
                    .disabled(!formularioValido)
                }
            }
        }
    }
}

#Preview {
    EditarItemWishlistView(
        item: ItemWishlist(nombre: "AirPods", emoji: "🎧", costoEnPuntos: 500)
    ) { _ in }
}
