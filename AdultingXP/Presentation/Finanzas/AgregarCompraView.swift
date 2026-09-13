import SwiftUI

private let opcionesCuotas = [1, 2, 3, 6, 9, 12, 18, 24, 36]

struct AgregarCompraView: View {
    let tarjetaId: UUID
    let onGuardar: (Compra) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var descripcion = ""
    @State private var montoTexto = ""
    @State private var numeroCuotas = 1
    @State private var fechaCompra = Date.now

    private var monto: Double { Double(montoTexto.replacingOccurrences(of: ",", with: ".")) ?? 0 }

    private var formularioValido: Bool {
        !descripcion.trimmingCharacters(in: .whitespaces).isEmpty && monto > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Descripción de la compra", text: $descripcion)
                    TextField("Monto total", text: $montoTexto)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Picker("Cuotas", selection: $numeroCuotas) {
                        ForEach(opcionesCuotas, id: \.self) { n in
                            Text(n == 1 ? "Contado" : "\(n) cuotas").tag(n)
                        }
                    }

                    if numeroCuotas > 1 && monto > 0 {
                        HStack {
                            Text("Por cuota")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text((monto / Double(numeroCuotas)).moneda)
                                .bold()
                        }
                        .font(.appCaption)
                    }
                } header: {
                    Text("Financiamiento")
                } footer: {
                    Text("Las cuotas se calculan automáticamente según el día de corte de tu tarjeta.")
                }

                Section {
                    DatePicker(
                        "Fecha de compra",
                        selection: $fechaCompra,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("Nueva compra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onGuardar(Compra(
                            tarjetaId: tarjetaId,
                            descripcion: descripcion.trimmingCharacters(in: .whitespaces),
                            montoTotal: monto,
                            numeroCuotas: numeroCuotas,
                            fechaCompra: fechaCompra
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
    AgregarCompraView(tarjetaId: UUID()) { _ in }
}
