import SwiftUI

private let opcionesTasa: [Double] = [50, 100, 200, 500, 1_000, 2_000, 5_000, 10_000]

struct WishlistSettingsView: View {
    @AppStorage(UserSettings.Keys.tasaCambio) private var tasaCambio: Double = 100

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("1 punto equivale a", selection: $tasaCambio) {
                        ForEach(opcionesTasa, id: \.self) { valor in
                            Text(valor.moneda).tag(valor)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Tasa de cambio")
                } footer: {
                    Text("Convierte tus puntos a pesos para que veas el valor real de cada recompensa.")
                }

                Section("Vista previa") {
                    HStack {
                        Text("100 pts")
                        Spacer()
                        Text("≈ \((100 * tasaCambio).moneda)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("500 pts")
                        Spacer()
                        Text("≈ \((500 * tasaCambio).moneda)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("1 000 pts")
                        Spacer()
                        Text("≈ \((1_000 * tasaCambio).moneda)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WishlistSettingsView()
}
