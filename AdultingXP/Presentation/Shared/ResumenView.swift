import SwiftUI
import Charts

// MARK: — ViewModel

@Observable
private final class ResumenViewModel {
    private let habitoRepo   = HabitoRepository()
    private let tareaRepo    = TareaRepository()
    private let wishlistRepo = WishlistRepository()
    private let tarjetaRepo  = TarjetaCreditoRepository()
    private let compraRepo   = CompraRepository()
    private let registroRepo = RegistroPuntosRepository()

    var habitos:  [Habito]          = []
    var tareas:   [Tarea]           = []
    var items:    [ItemWishlist]     = []
    var tarjetas: [TarjetaCredito]  = []
    var compras:  [Compra]          = []
    var registros: [RegistroPuntos] = []

    func recargar() {
        habitos   = habitoRepo.cargar()
        tareas    = tareaRepo.cargar()
        items     = wishlistRepo.cargar()
        tarjetas  = tarjetaRepo.cargar()
        compras   = compraRepo.cargar()
        registros = registroRepo.cargar()
    }

    // MARK: Balance
    var balanceGlobal: Int { registros.reduce(0) { $0 + $1.cantidad } }

    // MARK: Hábitos
    var habitosCompletadosHoy: Int {
        habitos.filter { h in
            guard let f = h.fechaUltimaCompletacion else { return false }
            return Calendar.current.isDateInToday(f)
        }.count
    }
    var rachaMaxima: Int { habitos.map(\.streakActual).max() ?? 0 }

    // MARK: Tareas
    var tareasPendientes: Int       { tareas.filter { !$0.completada }.count }
    var tareasCompletadas: Int      { tareas.filter {  $0.completada }.count }
    var tareasATiempo: Int          { tareas.filter { $0.fueCompletadaATiempo == true }.count }
    var porcentajeATiempo: Int {
        guard tareasCompletadas > 0 else { return 0 }
        return Int(Double(tareasATiempo) / Double(tareasCompletadas) * 100)
    }

    // MARK: Wishlist
    var proximaMeta: ItemWishlist? {
        items.filter { !$0.reclamado }
             .max { progresoWishlist($0) < progresoWishlist($1) }
    }
    func progresoWishlist(_ item: ItemWishlist) -> Double {
        guard item.costoEnPuntos > 0 else { return 1 }
        return min(1, max(0, Double(balanceGlobal) / Double(item.costoEnPuntos)))
    }

    // MARK: Gráfica
    var puntosUltimos7Dias: [(fecha: Date, total: Int)] {
        let cal = Calendar.current
        let hoy = cal.startOfDay(for: .now)
        return (0..<7).reversed().map { diasAtras in
            let dia = cal.date(byAdding: .day, value: -diasAtras, to: hoy)!
            let total = registros
                .filter { cal.isDate($0.fecha, inSameDayAs: dia) }
                .reduce(0) { $0 + $1.cantidad }
            return (fecha: dia, total: total)
        }
    }

    // MARK: Finanzas
    var deudaTotal: Double {
        tarjetas.reduce(0) { acum, tarjeta in
            let activas = compras.filter { $0.tarjetaId == tarjeta.id && !$0.estaPagada(diaCorte: tarjeta.diaCorte) }
            return acum + activas.reduce(0) { $0 + $1.saldoPendiente(diaCorte: tarjeta.diaCorte) }
        }
    }
    var limiteTotal: Double { tarjetas.reduce(0) { $0 + $1.limiteCredito } }
}

// MARK: — Vista

struct ResumenView: View {
    @State private var vm = ResumenViewModel()
    @State private var mostrandoConfig = false
    @AppStorage(UserSettings.Keys.tasaCambio) private var tasaCambio: Double = 100

    var body: some View {
        NavigationStack {
            List {
                balanceSection
                graficaSection
                if !vm.habitos.isEmpty  { habitosSection }
                if !vm.tareas.isEmpty   { tareasSection }
                if let meta = vm.proximaMeta { wishlistSection(meta) }
                if !vm.tarjetas.isEmpty { finanzasSection }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Resumen")
            .onAppear { vm.recargar() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Configuración", systemImage: "gearshape") {
                        mostrandoConfig = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: textoCompartir) {
                        Label("Compartir", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $mostrandoConfig) {
                ConfiguracionView()
            }
        }
    }

    private var textoCompartir: String {
        let fecha = Date.now.formatted(.dateTime.day().month(.wide).year()
            .locale(Locale(identifier: "es_CO")))
        var lineas = ["📊 Resumen AdultingXP — \(fecha)", ""]

        let signo = vm.balanceGlobal >= 0 ? "+" : ""
        lineas.append("Balance: \(signo)\(vm.balanceGlobal) pts  ≈ \((Double(vm.balanceGlobal) * tasaCambio).moneda)")

        if !vm.habitos.isEmpty {
            lineas.append("🎯 Hábitos: \(vm.habitosCompletadosHoy)/\(vm.habitos.count) hoy · racha máxima \(vm.rachaMaxima) días")
        }
        if !vm.tareas.isEmpty {
            lineas.append("📚 Tareas: \(vm.tareasPendientes) pendientes · \(vm.porcentajeATiempo)% a tiempo")
        }
        if let meta = vm.proximaMeta {
            lineas.append("🎁 Meta: \(meta.emoji) \(meta.nombre) — \(Int(vm.progresoWishlist(meta) * 100))%")
        }
        if !vm.tarjetas.isEmpty {
            lineas.append("💳 Finanzas: deuda \(vm.deudaTotal.moneda) / límite \(vm.limiteTotal.moneda)")
        }

        lineas.append("")
        lineas.append("Generado con AdultingXP")
        return lineas.joined(separator: "\n")
    }

    // MARK: — Balance

    private var balanceSection: some View {
        Section {
            NavigationLink { HistorialView() } label: {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Balance global")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                        Text("\(vm.balanceGlobal >= 0 ? "+" : "")\(vm.balanceGlobal) pts")
                            .font(.appDisplay)
                            .foregroundStyle(vm.balanceGlobal >= 0 ? Color.appPositive : Color.appNegative)
                            .contentTransition(.numericText())
                        Text("≈ \((Double(vm.balanceGlobal) * tasaCambio).moneda)")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: vm.balanceGlobal >= 0
                          ? "arrow.up.right.circle.fill"
                          : "arrow.down.right.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(vm.balanceGlobal >= 0 ? Color.appPositive : Color.appNegative)
                }
                .padding(.vertical, Spacing.xs)
            }
        }
    }

    // MARK: — Gráfica semanal

    private var graficaSection: some View {
        Section("Últimos 7 días") {
            Chart(vm.puntosUltimos7Dias, id: \.fecha) { punto in
                BarMark(
                    x: .value("Día", punto.fecha, unit: .day),
                    y: .value("Pts", punto.total)
                )
                .foregroundStyle(punto.total >= 0 ? Color.appPositive : Color.appNegative)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 140)
            .padding(.vertical, Spacing.sm)
        }
    }

    // MARK: — Hábitos

    private var habitosSection: some View {
        Section("Hábitos") {
            HStack {
                StatCell(
                    titulo: "Hoy",
                    valor: "\(vm.habitosCompletadosHoy)/\(vm.habitos.count)",
                    color: vm.habitosCompletadosHoy == vm.habitos.count ? .appPositive : .primary
                )
                Divider()
                StatCell(
                    titulo: "Racha máxima",
                    valor: "🔥 \(vm.rachaMaxima)",
                    color: vm.rachaMaxima > 0 ? .appPositive : .secondary
                )
            }

            ProgressView(
                value: Double(vm.habitosCompletadosHoy),
                total: Double(max(1, vm.habitos.count))
            )
            .tint(vm.habitosCompletadosHoy == vm.habitos.count ? .appPositive : .appAccent)
            .animation(AppAnimation.standard, value: vm.habitosCompletadosHoy)
        }
    }

    // MARK: — Tareas

    private var tareasSection: some View {
        Section("Tareas") {
            HStack {
                StatCell(
                    titulo: "Pendientes",
                    valor: "\(vm.tareasPendientes)",
                    color: vm.tareasPendientes > 0 ? .appWarning : .appPositive
                )
                Divider()
                StatCell(
                    titulo: "A tiempo",
                    valor: "\(vm.porcentajeATiempo)%",
                    color: vm.porcentajeATiempo >= 80 ? .appPositive : .appWarning
                )
            }
        }
    }

    // MARK: — Wishlist meta

    private func wishlistSection(_ meta: ItemWishlist) -> some View {
        Section("Próxima meta") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text(meta.emoji).font(.title2)
                    Text(meta.nombre).font(.appHeadline)
                    Spacer()
                    Text("\(Int(vm.progresoWishlist(meta) * 100))%")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: vm.progresoWishlist(meta))
                    .tint(vm.progresoWishlist(meta) >= 1 ? .appPositive : .appAccent)
                    .animation(AppAnimation.standard, value: vm.progresoWishlist(meta))
                Text("\(meta.costoEnPuntos) pts necesarios")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, Spacing.xs)
        }
    }

    // MARK: — Finanzas

    private var finanzasSection: some View {
        Section("Finanzas") {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    StatCell(titulo: "Deuda total", valor: vm.deudaTotal.moneda, color: vm.deudaTotal > 0 ? .appNegative : .appPositive)
                    Divider()
                    StatCell(titulo: "Límite total", valor: vm.limiteTotal.moneda, color: .primary)
                }
                if vm.limiteTotal > 0 {
                    let ratio = min(1, vm.deudaTotal / vm.limiteTotal)
                    ProgressView(value: ratio)
                        .tint(ratio > 0.7 ? .appNegative : .appAccent)
                        .animation(AppAnimation.standard, value: ratio)
                }
            }
        }
    }
}

// MARK: — Celda de estadística

private struct StatCell: View {
    let titulo: String
    let valor: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(titulo)
                .font(.appCaption)
                .foregroundStyle(.secondary)
            Text(valor)
                .font(.appHeadline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    ResumenView()
}
