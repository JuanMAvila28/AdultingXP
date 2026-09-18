import SwiftUI

struct PomodoroView: View {
    @State private var vm = PomodoroViewModel()
    @State private var mostrarConfig = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    anilloSection
                    controlesSection
                    contadorSection
                    balanceSection
                    if !vm.sesiones.isEmpty {
                        sesionesRecientesSection
                    }
                }
                .padding()
            }
            .navigationTitle("Pomodoro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { mostrarConfig = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: HistorialView()) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .sheet(isPresented: $mostrarConfig) {
                PomodoroSettingsView()
            }
        }
    }

    // MARK: — Anillo

    private var colorAnillo: Color {
        guard let sesion = vm.sesionActual else { return .appAccent }
        return Color(hex: vm.colorSesion(para: sesion.tipo))
    }

    private var anilloSection: some View {
        ZStack {
            Circle()
                .stroke(colorAnillo.opacity(0.15), lineWidth: 16)
            Circle()
                .trim(from: 0, to: vm.progreso)
                .stroke(colorAnillo, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: vm.progreso)
            VStack(spacing: 6) {
                Text(formatearTiempo(vm.segundosRestantes))
                    .font(.system(size: 56, weight: .thin, design: .monospaced))
                    .contentTransition(.numericText())
                Text(etiquetaSesion)
                    .font(.callout)
                    .foregroundStyle(Color.appSecondary)
            }
        }
        .frame(width: 260, height: 260)
        .padding(.top, 8)
    }

    private var etiquetaSesion: String {
        guard let sesion = vm.sesionActual else { return "Listo para empezar" }
        switch sesion.estado {
        case .enProgreso:   return sesion.tipo.label
        case .pausado:      return "En pausa · \(sesion.tipo.label)"
        case .completada:   return sesion.tipo.esTrabajo ? "¡Completado!" : "Descanso terminado"
        case .interrumpida: return "Cancelada"
        }
    }

    // MARK: — Controles

    @ViewBuilder
    private var controlesSection: some View {
        if let sesion = vm.sesionActual {
            switch sesion.estado {
            case .enProgreso:
                HStack(spacing: 16) {
                    Button { vm.pausar() } label: {
                        Label("Pausar", systemImage: "pause.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    Button { vm.cancelar() } label: {
                        Label("Cancelar", systemImage: "xmark").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.appNegative)
                }
            case .pausado:
                HStack(spacing: 16) {
                    Button { vm.reanudar() } label: {
                        Label("Reanudar", systemImage: "play.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    Button { vm.cancelar() } label: {
                        Label("Cancelar", systemImage: "xmark").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.appNegative)
                }
            case .completada:
                VStack(spacing: 12) {
                    Label(
                        sesion.tipo.esTrabajo ? "¡Sesión completada! 🍅" : "¡Descanso terminado!",
                        systemImage: sesion.tipo.esTrabajo ? "checkmark.seal.fill" : "cup.and.saucer.fill"
                    )
                    .foregroundStyle(Color.appPositive)
                    Button { vm.iniciarSiguiente() } label: {
                        Label("Iniciar \(vm.siguienteTipo.label)", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            case .interrumpida:
                Button { vm.iniciar(tipo: .trabajo) } label: {
                    Label("Iniciar trabajo", systemImage: "play.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            Button { vm.iniciar(tipo: .trabajo) } label: {
                Label("Iniciar trabajo", systemImage: "play.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: — Contador

    private var contadorSection: some View {
        HStack {
            Text("\(vm.sesionesTrabajoHoy) 🍅 hoy")
                .font(.callout)
                .foregroundStyle(Color.appSecondary)
            Spacer()
            Text("\(vm.puntosPorSesion) pts por sesión")
                .font(.callout)
                .foregroundStyle(Color.appSecondary)
        }
    }

    // MARK: — Balance

    private var balanceSection: some View {
        NavigationLink(destination: HistorialView()) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Balance global")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondary)
                    Text("\(vm.balanceGlobal >= 0 ? "+" : "")\(vm.balanceGlobal) pts")
                        .font(.title3.bold())
                        .foregroundStyle(vm.balanceGlobal >= 0 ? Color.appPositive : Color.appNegative)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appSecondary)
                    .font(.caption)
            }
            .padding()
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: — Sesiones recientes

    private var sesionesRecientesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recientes")
                .font(.headline)
            ForEach(vm.sesiones.suffix(5).reversed()) { sesion in
                filaHistorial(sesion)
            }
        }
    }

    private func filaHistorial(_ sesion: SesionPomodoro) -> some View {
        HStack {
            Image(systemName: iconoTipo(sesion.tipo))
                .foregroundStyle(Color(hex: vm.colorSesion(para: sesion.tipo)))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(sesion.tipo.label)
                    .font(.subheadline)
                Text(sesion.fechaInicio.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Color.appSecondary)
            }
            Spacer()
            Text(etiquetaEstado(sesion.estado))
                .font(.caption)
                .foregroundStyle(colorEstado(sesion.estado))
        }
        .padding(.vertical, 4)
    }

    // MARK: — Helpers

    private func formatearTiempo(_ segundos: Int) -> String {
        String(format: "%02d:%02d", segundos / 60, segundos % 60)
    }

    private func iconoTipo(_ tipo: TipoSesionPomodoro) -> String {
        switch tipo {
        case .trabajo:       return "timer"
        case .descansoCorto: return "cup.and.saucer"
        case .descansoLargo: return "figure.walk"
        }
    }

    private func etiquetaEstado(_ estado: EstadoSesion) -> String {
        switch estado {
        case .enProgreso:   return "En progreso"
        case .pausado:      return "Pausado"
        case .completada:   return "Completada"
        case .interrumpida: return "Cancelada"
        }
    }

    private func colorEstado(_ estado: EstadoSesion) -> Color {
        switch estado {
        case .completada:   return .appPositive
        case .interrumpida: return .appNegative
        default:            return .appSecondary
        }
    }
}

#Preview {
    PomodoroView()
}
