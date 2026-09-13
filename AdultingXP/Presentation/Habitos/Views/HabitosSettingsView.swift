import SwiftUI

struct HabitosSettingsView: View {
    @AppStorage(UserSettings.Keys.diaCorteSemanal) private var diaCorteSemanal = 2

    private var nombresDias: [String] {
        Calendar.current.standaloneWeekdaySymbols.map { $0.capitalized }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Día de corte", selection: $diaCorteSemanal) {
                        ForEach(1...7, id: \.self) { weekday in
                            Text(nombresDias[weekday - 1]).tag(weekday)
                        }
                    }
                } header: {
                    Text("Hábitos semanales")
                } footer: {
                    Text("Los hábitos semanales deben completarse antes de este día para mantener la racha.")
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HabitosSettingsView()
}
