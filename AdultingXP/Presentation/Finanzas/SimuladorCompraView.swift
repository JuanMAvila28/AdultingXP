import SwiftUI

private let opcionesCuotas = [1, 2, 3, 6, 9, 12, 18, 24, 36]

struct SimuladorCompraView: View {
    let tarjeta: TarjetaCredito
    let cuotaMesActual: Double
    let deudaActual: Double
    let cupoActual: Double

    @Environment(\.dismiss) private var dismiss
    @State private var montoTexto = ""
    @State private var numeroCuotas = 1

    private var monto: Double {
        Double(montoTexto.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var nuevaCuota: Double {
        guard numeroCuotas > 0, monto > 0 else { return 0 }
        return monto / Double(numeroCuotas)
    }

    private var nuevaCuotaMes: Double  { cuotaMesActual + nuevaCuota }
    private var nuevaDeuda: Double     { deudaActual + monto }
    private var nuevoCupo: Double      { cupoActual - monto }
    private var superaCupo: Bool       { nuevoCupo < 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Monto de la compra", text: $montoTexto)
                        .keyboardType(.decimalPad)

                    Picker("Cuotas", selection: $numeroCuotas) {
                        ForEach(opcionesCuotas, id: \.self) { n in
                            Text(n == 1 ? "Contado" : "\(n) cuotas").tag(n)
                        }
                    }

                    if monto > 0 && numeroCuotas > 1 {
                        HStack {
                            Text("Por cuota")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(nuevaCuota.moneda)
                                .bold()
                        }
                        .font(.appCaption)
                    }
                } header: {
                    Text("Compra hipotética")
                } footer: {
                    Text("Ningún dato se guarda. Es solo un cálculo de impacto.")
                }

                if monto > 0 {
                    Section("Impacto en \(tarjeta.nombre)") {
                        SimuladorRow(
                            titulo: "Cuota mensual",
                            antes: cuotaMesActual,
                            despues: nuevaCuotaMes,
                            mejora: false
                        )
                        SimuladorRow(
                            titulo: "Deuda total",
                            antes: deudaActual,
                            despues: nuevaDeuda,
                            mejora: false
                        )
                        SimuladorRow(
                            titulo: "Cupo disponible",
                            antes: cupoActual,
                            despues: nuevoCupo,
                            mejora: !superaCupo
                        )
                    }

                    if superaCupo {
                        Section {
                            Label(
                                "Esta compra supera tu cupo en \((-nuevoCupo).moneda).",
                                systemImage: "exclamationmark.triangle.fill"
                            )
                            .foregroundStyle(Color.appNegative)
                            .font(.appCaption)
                        }
                    }
                }
            }
            .navigationTitle("Simulador")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

// MARK: — Fila de comparación antes/después

private struct SimuladorRow: View {
    let titulo: String
    let antes: Double
    let despues: Double
    let mejora: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(titulo)
                .font(.appCaption)
                .foregroundStyle(.secondary)

            HStack(spacing: Spacing.sm) {
                Text(antes.moneda)
                    .strikethrough()
                    .foregroundStyle(.secondary)

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(despues.moneda)
                    .fontWeight(.semibold)
                    .foregroundStyle(mejora ? Color.appPositive : Color.appNegative)
                    .contentTransition(.numericText())
                    .animation(AppAnimation.standard, value: despues)
            }
            .font(.appHeadline)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    SimuladorCompraView(
        tarjeta: TarjetaCredito(
            nombre: "Visa Preferencia",
            banco: "Bancolombia",
            limiteCredito: 10_000_000,
            diaCorte: 20,
            diaPago: 10
        ),
        cuotaMesActual: 450_000,
        deudaActual: 2_700_000,
        cupoActual: 7_300_000
    )
}
