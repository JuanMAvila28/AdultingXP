import SwiftUI

struct HabitoDetailView: View {
    let habito: Habito
    let registros: [RegistroPuntos]

    private var registrosCompletacion: [RegistroPuntos] {
        registros.filter { $0.origen == .habito && $0.concepto == habito.nombre }
    }

    private var puntosGenerados: Int {
        registros
            .filter { ($0.origen == .habito || $0.origen == .bonusStreak) &&
                       $0.concepto.contains(habito.nombre) }
            .reduce(0) { $0 + $1.cantidad }
    }

    private var diasCompletados: Set<Date> {
        Set(registrosCompletacion.map { Calendar.current.startOfDay(for: $0.fecha) })
    }

    // Lunes de hace 4 semanas → 28 celdas
    private var diasDelGrid: [Date] {
        let cal = Calendar.current
        var comp = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)
        comp.weekday = 2 // lunes
        let inicioSemana = cal.date(from: comp) ?? .now
        let inicio = cal.date(byAdding: .weekOfYear, value: -3, to: inicioSemana)!
        return (0..<28).map { cal.date(byAdding: .day, value: $0, to: inicio)! }
    }

    var body: some View {
        List {
            headerSection
            statsSection
            gridSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(habito.nombre)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: — Header

    private var headerSection: some View {
        Section {
            HStack(spacing: Spacing.md) {
                Text(habito.emoji)
                    .font(.system(size: 52))
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(habito.nombre).font(.appTitle)
                    Text("\(habito.categoria) · \(habito.frecuencia.label)")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Text("\(habito.esBueno ? "+" : "−")\(habito.puntajeBase) pts por ocurrencia")
                        .font(.appCaption)
                        .foregroundStyle(habito.esBueno ? Color.appPositive : Color.appNegative)
                }
            }
            .padding(.vertical, Spacing.xs)
        }
    }

    // MARK: — Stats

    private var statsSection: some View {
        Section {
            HStack {
                DetalleStatCell(titulo: "Ocurrencias", valor: "×\(registrosCompletacion.count)")
                Divider()
                DetalleStatCell(
                    titulo: "Puntos",
                    valor: "\(puntosGenerados >= 0 ? "+" : "")\(puntosGenerados)",
                    color: puntosGenerados >= 0 ? .appPositive : .appNegative
                )
                Divider()
                DetalleStatCell(
                    titulo: "Racha",
                    valor: habito.streakActual > 0 ? "🔥 \(habito.streakActual)" : "—",
                    color: habito.streakActual > 0 ? .appPositive : .secondary
                )
            }
        }
    }

    // MARK: — Grid calendario

    private var gridSection: some View {
        Section("Últimos 28 días") {
            VStack(spacing: Spacing.sm) {
                // Cabecera días
                HStack(spacing: 0) {
                    ForEach(["L", "M", "X", "J", "V", "S", "D"], id: \.self) { d in
                        Text(d)
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Celdas
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7),
                    spacing: 6
                ) {
                    ForEach(diasDelGrid, id: \.self) { dia in
                        celdaDia(dia)
                    }
                }
            }
            .padding(.vertical, Spacing.sm)
        }
    }

    @ViewBuilder
    private func celdaDia(_ dia: Date) -> some View {
        let cal = Calendar.current
        let hoy = cal.startOfDay(for: .now)
        let esFuturo = dia > hoy
        let completado = diasCompletados.contains(dia)
        let numero = cal.component(.day, from: dia)

        ZStack {
            Circle()
                .fill(
                    completado ? Color.appPositive :
                    esFuturo   ? Color.clear :
                                 Color.secondary.opacity(0.12)
                )

            Text("\(numero)")
                .font(.system(size: 11, weight: completado ? .semibold : .regular))
                .foregroundStyle(
                    completado ? .white :
                    esFuturo   ? Color.secondary.opacity(0.4) :
                                 Color.primary.opacity(0.6)
                )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: — Celda de estadística

private struct DetalleStatCell: View {
    let titulo: String
    let valor: String
    var color: Color = .primary

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
    NavigationStack {
        HabitoDetailView(
            habito: Habito(
                nombre: "Leer",
                emoji: "📚",
                categoria: "Estudio",
                esBueno: true,
                puntajeBase: 20,
                frecuencia: .diario
            ),
            registros: []
        )
    }
}
