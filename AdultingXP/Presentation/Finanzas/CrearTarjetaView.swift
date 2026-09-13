import SwiftUI

private let coloresDisponibles = [
    "#5E4ADB", "#2563EB", "#7C3AED",
    "#059669", "#DC2626", "#D97706",
    "#0891B2", "#374151"
]

struct CrearTarjetaView: View {
    let onGuardar: (TarjetaCredito) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var nombre = ""
    @State private var banco = ""
    @State private var limiteTexto = ""
    @State private var diaCorte = 20
    @State private var diaPago = 10
    @State private var colorHex = coloresDisponibles[0]

    private var limite: Double { Double(limiteTexto) ?? 0 }

    private var formularioValido: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !banco.trimmingCharacters(in: .whitespaces).isEmpty &&
        limite > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre de la tarjeta", text: $nombre)
                    TextField("Banco", text: $banco)
                    TextField("Límite de crédito", text: $limiteTexto)
                        .keyboardType(.decimalPad)
                }

                Section("Fechas de facturación") {
                    Picker("Día de corte", selection: $diaCorte) {
                        ForEach(1...28, id: \.self) { Text("Día \($0)").tag($0) }
                    }
                    Picker("Día de pago", selection: $diaPago) {
                        ForEach(1...28, id: \.self) { Text("Día \($0)").tag($0) }
                    }
                }

                Section("Color") {
                    colorPicker
                }
            }
            .navigationTitle("Nueva tarjeta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onGuardar(TarjetaCredito(
                            nombre: nombre.trimmingCharacters(in: .whitespaces),
                            banco: banco.trimmingCharacters(in: .whitespaces),
                            limiteCredito: limite,
                            diaCorte: diaCorte,
                            diaPago: diaPago,
                            colorHex: colorHex
                        ))
                        dismiss()
                    }
                    .disabled(!formularioValido)
                }
            }
        }
    }

    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(coloresDisponibles, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: colorHex == hex ? 3 : 0)
                                .padding(2)
                        )
                        .shadow(color: Color(hex: hex).opacity(0.5), radius: colorHex == hex ? 6 : 0)
                        .onTapGesture { colorHex = hex }
                        .animation(AppAnimation.quick, value: colorHex)
                }
            }
            .padding(.vertical, Spacing.xs)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0))
    }
}

#Preview {
    CrearTarjetaView { _ in }
}
