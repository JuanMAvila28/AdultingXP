import SwiftUI

private let opcionesCuotas = [1, 2, 3, 6, 9, 12, 18, 24, 36]

struct ComprarConTarjetaView: View {
    let item: ItemWishlist
    let onComprar: (_ tarjetaId: UUID, _ numeroCuotas: Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage(UserSettings.Keys.tasaCambio) private var tasaCambio: Double = 100

    @State private var tarjetas: [TarjetaCredito] = []
    @State private var tarjetaSeleccionada: TarjetaCredito? = nil
    @State private var numeroCuotas = 1

    private var montoEnPesos: Double { Double(item.costoEnPuntos) * tasaCambio }
    private var montoPorCuota: Double { montoEnPesos / Double(max(1, numeroCuotas)) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: Spacing.md) {
                        Text(item.emoji).font(.title2)
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(item.nombre).font(.appHeadline)
                            Text("\(item.costoEnPuntos) pts  ≈ \(montoEnPesos.moneda)")
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                }

                if tarjetas.isEmpty {
                    Section {
                        Label(
                            "No tienes tarjetas registradas. Agrégalas en Finanzas.",
                            systemImage: "creditcard.trianglebadge.exclamationmark"
                        )
                        .foregroundStyle(.secondary)
                        .font(.appCaption)
                    }
                } else {
                    Section("Tarjeta") {
                        Picker("Tarjeta", selection: $tarjetaSeleccionada) {
                            ForEach(tarjetas) { tarjeta in
                                Text("\(tarjeta.nombre) — \(tarjeta.banco)")
                                    .tag(Optional(tarjeta))
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Section {
                        Picker("Cuotas", selection: $numeroCuotas) {
                            ForEach(opcionesCuotas, id: \.self) { n in
                                Text(n == 1 ? "Contado" : "\(n) cuotas").tag(n)
                            }
                        }
                        .pickerStyle(.menu)

                        HStack {
                            Text("Por cuota")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(montoPorCuota.moneda).bold()
                        }
                        .font(.appCaption)
                    } header: {
                        Text("Financiamiento")
                    } footer: {
                        Text("Se registrará en Finanzas. Los puntos de Wishlist no se afectan.")
                    }
                }
            }
            .navigationTitle("Comprar con tarjeta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") {
                        guard let tarjeta = tarjetaSeleccionada else { return }
                        onComprar(tarjeta.id, numeroCuotas)
                        dismiss()
                    }
                    .disabled(tarjetaSeleccionada == nil)
                }
            }
            .onAppear {
                tarjetas = TarjetaCreditoRepository().cargar()
                tarjetaSeleccionada = tarjetas.first
            }
        }
    }
}

#Preview {
    ComprarConTarjetaView(
        item: ItemWishlist(nombre: "AirPods Pro", emoji: "🎧", costoEnPuntos: 500)
    ) { _, _ in }
}
