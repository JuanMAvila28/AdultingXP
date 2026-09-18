import SwiftUI

struct TiempoPantallaView: View {
    @State private var vm = TiempoPantallaViewModel()
    @AppStorage(UserSettings.Keys.pantallaLimite)       private var limite       = 120
    @AppStorage(UserSettings.Keys.pantallaPuntos)       private var puntos       = 15
    @AppStorage(UserSettings.Keys.pantallaPenalizacion) private var penalizacion = 10
    @State private var mostrarConfig = false

    var body: some View {
        NavigationStack {
            Form {
                registroSemanalSection
                if !vm.registrosOrdenados.isEmpty {
                    historialSection
                }
            }
            .navigationTitle("Tiempo en Pantalla")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { mostrarConfig = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $mostrarConfig) {
                TiempoPantallaSettingsView()
            }
        }
    }

    // MARK: — Registro semanal

    private var registroSemanalSection: some View {
        Section {
            HStack {
                Text("Minutos usados esta semana")
                Spacer()
                TextField("ej. 90", value: $vm.minutosIngresados, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Límite semanal")
                Spacer()
                Text("\(limite) min")
                    .foregroundStyle(Color.appSecondary)
            }

            if vm.minutosIngresados > 0 {
                previstaSection
            }

            Button {
                vm.registrar(limite: limite, puntos: puntos, penalizacion: penalizacion)
            } label: {
                Text(vm.registroSemanaActual == nil ? "Guardar registro" : "Actualizar registro")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.minutosIngresados <= 0)
            .sensoryFeedback(.success, trigger: vm.guardadoExitoso)
        } header: {
            Text("Esta semana")
        } footer: {
            if vm.registroSemanaActual != nil {
                Text("Actualizar reemplaza el registro de esta semana y corrige los puntos.")
            }
        }
    }

    @ViewBuilder
    private var previstaSection: some View {
        if vm.minutosIngresados <= limite {
            HStack {
                Label("Cumplirás el límite", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.appPositive)
                Spacer()
                Text("+\(puntos) pts")
                    .foregroundStyle(Color.appPositive)
                    .bold()
            }
        } else {
            HStack {
                Label("Excederás el límite", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.appNegative)
                Spacer()
                Text("-\(penalizacion) pts")
                    .foregroundStyle(Color.appNegative)
                    .bold()
            }
        }
    }

    // MARK: — Historial

    private var historialSection: some View {
        Section("Historial") {
            ForEach(vm.registrosOrdenados) { registro in
                filaRegistro(registro)
            }
        }
    }

    private func filaRegistro(_ registro: RegistroTiempoPantalla) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(registro.etiquetaSemana)
                    .font(.subheadline)
                HStack(spacing: 4) {
                    Text("\(registro.minutosUsados) / \(registro.minutosLimite) min")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondary)
                    if registro.cumplioLimite {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appPositive)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appNegative)
                    }
                }
            }
            Spacer()
            Text(registro.puntosOtorgados >= 0 ? "+\(registro.puntosOtorgados) pts" : "\(registro.puntosOtorgados) pts")
                .font(.subheadline.bold())
                .foregroundStyle(registro.cumplioLimite ? Color.appPositive : Color.appNegative)
        }
    }
}

// MARK: — Settings

private struct TiempoPantallaSettingsView: View {
    @AppStorage(UserSettings.Keys.pantallaLimite)       private var limite       = 120
    @AppStorage(UserSettings.Keys.pantallaPuntos)       private var puntos       = 15
    @AppStorage(UserSettings.Keys.pantallaPenalizacion) private var penalizacion = 10
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Límite semanal") {
                    Stepper("Límite: \(limite) min", value: $limite, in: 30...720, step: 30)
                }
                Section("Puntos") {
                    Stepper("Por cumplir: \(puntos) pts", value: $puntos, in: 1...100)
                    Stepper("Penalización: \(penalizacion) pts", value: $penalizacion, in: 1...100)
                }
                Section {
                    Text("Registra tu tiempo de pantalla semanal manualmente. Puedes consultarlo en la app Tiempo en Pantalla de iOS.")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondary)
                }
            }
            .navigationTitle("Ajustes Pantalla")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    TiempoPantallaView()
}
