import SwiftUI

private let opcionesCuotas = [1, 2, 3, 6, 9, 12, 18, 24, 36]

struct EditarCompraView: View {
    let compra: Compra
    let onGuardar: (Compra) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var descripcion: String
    @State private var montoTexto: String
    @State private var numeroCuotas: Int
    @State private var fechaCompra: Date

    init(compra: Compra, onGuardar: @escaping (Compra) -> Void) {
        self.compra = compra
        self.onGuardar = onGuardar
        _descripcion  = State(initialValue: compra.descripcion)
        _montoTexto   = State(initialValue: String(Int(compra.montoTotal)))
        _numeroCuotas = State(initialValue: compra.numeroCuotas)
        _fechaCompra  = State(initialValue: compra.fechaCompra)
    }

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
                    Text("Las cuotas ya facturadas se recalculan automáticamente al guardar.")
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
            .navigationTitle("Editar compra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onGuardar(Compra(
                            id: compra.id,
                            tarjetaId: compra.tarjetaId,
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
    EditarCompraView(
        compra: Compra(
            tarjetaId: UUID(),
            descripcion: "Netflix",
            montoTotal: 50_000,
            numeroCuotas: 1
        )
    ) { _ in }
}
