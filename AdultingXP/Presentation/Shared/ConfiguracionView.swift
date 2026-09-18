import SwiftUI

private let opcionesTasa: [Double] = [50, 100, 200, 500, 1_000, 2_000, 5_000, 10_000]

struct ConfiguracionView: View {
    @AppStorage(UserSettings.Keys.diaCorteSemanal)  private var diaCorteSemanal = 2
    @AppStorage(UserSettings.Keys.tasaCambio)       private var tasaCambio: Double = 100
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
                // MARK: Hábitos
                Section {
                    Picker("Día de corte", selection: $diaCorteSemanal) {
                        ForEach(1...7, id: \.self) { Text(nombresDias[$0 - 1]).tag($0) }
                    }
                } header: {
                    Text("Hábitos semanales")
                } footer: {
                    Text("Los hábitos semanales deben completarse antes de este día para mantener la racha.")
                }

                // MARK: Notificaciones
                Section {
                    Toggle("Recordatorio diario", isOn: $recordatorioOn)
                        .onChange(of: recordatorioOn) { _, activo in
                            if activo {
                                Task {
                                    let ok = await service.solicitarPermiso()
                                    if ok {
                                        service.programarRecordatorio(hora: recordatorioHora, minuto: recordatorioMin)
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
                                    service.programarRecordatorio(hora: recordatorioHora, minuto: recordatorioMin)
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                } header: {
                    Text("Notificaciones")
                } footer: {
                    Text("Recibirás un aviso diario a la hora elegida.")
                }
                .animation(AppAnimation.standard, value: recordatorioOn)

                // MARK: Wishlist
                Section {
                    Picker("1 punto equivale a", selection: $tasaCambio) {
                        ForEach(opcionesTasa, id: \.self) { Text($0.moneda).tag($0) }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Tasa de cambio")
                } footer: {
                    Text("Convierte puntos a pesos para ver el valor real de cada recompensa.")
                }

                Section("Vista previa") {
                    ForEach([100.0, 500.0, 1_000.0], id: \.self) { pts in
                        HStack {
                            Text("\(Int(pts)) pts")
                            Spacer()
                            Text("≈ \((pts * tasaCambio).moneda)").foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ConfiguracionView()
}
