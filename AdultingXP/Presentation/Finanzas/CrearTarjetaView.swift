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

    // Cuota de manejo
    @State private var tieneCuotaManejo = false
    @State private var cuotaManejoTexto = ""

    // Interés
    @State private var tieneInteres = false
    @State private var tasaTexto = ""

    private var limite: Double { Double(limiteTexto) ?? 0 }
    private var cuotaManejo: Double? { tieneCuotaManejo ? Double(cuotaManejoTexto) : nil }
    private var tasaInteres: Double? {
        tieneInteres ? Double(tasaTexto.replacingOccurrences(of: ",", with: ".")) : nil
    }

    private var formularioValido: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !banco.trimmingCharacters(in: .whitespaces).isEmpty &&
        limite > 0 &&
        (!tieneCuotaManejo || (cuotaManejo ?? 0) > 0) &&
        (!tieneInteres || (tasaInteres ?? 0) > 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre de la tarjeta", text: $nombre)
                    TextField("Banco", text: $banco)

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Límite de crédito", text: $limiteTexto)
                            .keyboardType(.numberPad)
                        if limite > 0 {
                            Text(limite.moneda)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Fechas de facturación") {
                    Picker("Día de corte", selection: $diaCorte) {
                        ForEach(1...31, id: \.self) { Text("Día \($0)").tag($0) }
                    }
                    Picker("Día de pago", selection: $diaPago) {
                        ForEach(1...31, id: \.self) { Text("Día \($0)").tag($0) }
                    }
                }

                Section {
                    Toggle("Tiene cuota de manejo", isOn: $tieneCuotaManejo.animation())
                    if tieneCuotaManejo {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Valor mensual", text: $cuotaManejoTexto)
                                .keyboardType(.numberPad)
                            if let cm = cuotaManejo, cm > 0 {
                                Text(cm.moneda)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Cuota de manejo")
                }

                Section {
                    Toggle("Cobra interés", isOn: $tieneInteres.animation())
                    if tieneInteres {
                        HStack(spacing: Spacing.sm) {
                            TextField("Tasa mensual", text: $tasaTexto)
                                .keyboardType(.decimalPad)
                            Text("% mensual")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Interés")
                } footer: {
                    if tieneInteres {
                        Text("Tasa efectiva mensual (TEM). Ejemplo: 2.5 para 2,5%.")
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
                            colorHex: colorHex,
                            cuotaManejo: cuotaManejo,
                            tasaInteres: tasaInteres
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
