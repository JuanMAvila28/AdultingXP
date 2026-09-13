import SwiftUI

struct CrearItemWishlistView: View {
    let onGuardar: (ItemWishlist) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var emoji = "🎁"
    @State private var nombre = ""
    @State private var descripcion = ""
    @State private var costoEnPuntos = 100

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
                } footer: {
                    Text("Cuántos puntos necesitas para reclamar esta recompensa.")
                }
            }
            .navigationTitle("Nueva recompensa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onGuardar(ItemWishlist(
                            nombre: nombre.trimmingCharacters(in: .whitespaces),
                            emoji: emoji.isEmpty ? "🎁" : String(emoji.prefix(2)),
                            costoEnPuntos: costoEnPuntos,
                            descripcion: descripcion.trimmingCharacters(in: .whitespaces)
                        ))
                        dismiss()
                    }
                    .disabled(!formularioValido)
                }
            }
        }
    }
}

#Preview {
    CrearItemWishlistView { _ in }
}
