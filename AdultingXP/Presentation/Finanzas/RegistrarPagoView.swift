import SwiftUI

struct RegistrarPagoView: View {
    let tarjeta: TarjetaCredito
    let valorAPagar: Double
    let onGuardar: (Pago) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var montoTexto: String
    @State private var fechaPago = Date.now

    init(tarjeta: TarjetaCredito, valorAPagar: Double, onGuardar: @escaping (Pago) -> Void) {
        self.tarjeta = tarjeta
        self.valorAPagar = valorAPagar
        self.onGuardar = onGuardar
        _montoTexto = State(initialValue: valorAPagar > 0 ? String(Int(valorAPagar)) : "")
    }

    private var monto: Double { Double(montoTexto) ?? 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Monto pagado", text: $montoTexto)
                            .keyboardType(.numberPad)
                        if monto > 0 {
                            Text(monto.moneda)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    DatePicker(
                        "Fecha de pago",
                        selection: $fechaPago,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                } header: {
                    Text("Pago a \(tarjeta.nombre)")
                } footer: {
                    if valorAPagar > 0 {
                        Text("Balance calculado: \(valorAPagar.moneda). Puedes ajustar si pagaste un monto diferente.")
                    }
                }
            }
            .navigationTitle("Registrar pago")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onGuardar(Pago(
                            tarjetaId: tarjeta.id,
                            fechaPago: fechaPago,
                            montoPagado: monto,
                            balanceAntes: valorAPagar
                        ))
                        dismiss()
                    }
                    .disabled(monto <= 0)
                }
            }
        }
    }
}

#Preview {
    RegistrarPagoView(
        tarjeta: TarjetaCredito(
            nombre: "Visa Preferencia",
            banco: "Bancolombia",
            limiteCredito: 10_000_000,
            diaCorte: 20,
            diaPago: 10
        ),
        valorAPagar: 450_000
    ) { _ in }
}
