import SwiftUI

struct PomodoroSettingsView: View {
    @AppStorage(UserSettings.Keys.pomodoroTrabajo)  private var trabajo   = 25
    @AppStorage(UserSettings.Keys.pomodoroCorto)    private var corto     = 5
    @AppStorage(UserSettings.Keys.pomodoroLargo)    private var largo     = 15
    @AppStorage(UserSettings.Keys.pomodoroSesiones) private var sesiones  = 4
    @AppStorage(UserSettings.Keys.pomodoroPuntos)   private var puntos    = 10
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Duraciones") {
                    Stepper("Trabajo: \(trabajo) min", value: $trabajo, in: 1...90)
                    Stepper("Descanso corto: \(corto) min", value: $corto, in: 1...30)
                    Stepper("Descanso largo: \(largo) min", value: $largo, in: 1...60)
                    Stepper("Sesiones hasta descanso largo: \(sesiones)", value: $sesiones, in: 1...10)
                }
                Section("Puntos") {
                    Stepper("Por sesión de trabajo: \(puntos) pts", value: $puntos, in: 1...100)
                }
                Section {
                    Text("Los cambios se aplican a partir de la siguiente sesión.")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondary)
                }
            }
            .navigationTitle("Ajustes Pomodoro")
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
    PomodoroSettingsView()
}
