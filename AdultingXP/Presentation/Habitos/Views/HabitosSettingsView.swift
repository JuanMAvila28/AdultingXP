import SwiftUI

struct HabitosSettingsView: View {
    @AppStorage(UserSettings.Keys.diaCorteSemanal)  private var diaCorteSemanal = 2
    @AppStorage(UserSettings.Keys.recordatorioOn)   private var recordatorioOn  = false
    @AppStorage(UserSettings.Keys.recordatorioHora) private var recordatorioHora: Int = 8
    @AppStorage(UserSettings.Keys.recordatorioMin)  private var recordatorioMin:  Int = 0

    private let service = NotificacionesService.shared

    private var nombresDias: [String] {
        Calendar.current.standaloneWeekdaySymbols.map { $0.capitalized }
    }

    private var horaSeleccionada: Date {
        var c = DateComponents()
        c.hour = recordatorioHora
        c.minute = recordatorioMin
        return Calendar.current.date(from: c) ?? Date()
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

                Section {
                    Toggle("Recordatorio diario", isOn: $recordatorioOn)
                        .onChange(of: recordatorioOn) { _, activo in
                            if activo {
                                Task {
                                    let ok = await service.solicitarPermiso()
                                    if ok {
                                        service.programarRecordatorio(
                                            hora: recordatorioHora,
                                            minuto: recordatorioMin
                                        )
                                    } else {
                                        recordatorioOn = false
                                    }
                                }
                            } else {
                                service.cancelarRecordatorio()
                            }
                        }

                    if recordatorioOn {
                        DatePicker(
                            "Hora",
                            selection: Binding(
                                get: { horaSeleccionada },
                                set: { nueva in
                                    let c = Calendar.current.dateComponents([.hour, .minute], from: nueva)
                                    recordatorioHora = c.hour   ?? 8
                                    recordatorioMin  = c.minute ?? 0
                                    service.programarRecordatorio(
                                        hora: recordatorioHora,
                                        minuto: recordatorioMin
                                    )
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                } header: {
                    Text("Notificaciones")
                } footer: {
                    Text("Recibirás un recordatorio diario a la hora elegida si todavía hay hábitos pendientes.")
                }
                .animation(AppAnimation.standard, value: recordatorioOn)
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HabitosSettingsView()
}
