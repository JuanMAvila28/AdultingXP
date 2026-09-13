import SwiftUI
import Charts

struct FinanzasView: View {
    @State private var viewModel = FinanzasViewModel()
    @State private var mostrandoCrear = false
    @State private var tarjetaAEditar: TarjetaCredito? = nil
    @State private var tarjetaAEliminar: TarjetaCredito? = nil
    @State private var mostrandoConfirmacion = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.tarjetas.isEmpty {
                    ContentUnavailableView(
                        "Sin tarjetas",
                        systemImage: "creditcard",
                        description: Text("Toca + para agregar tu primera tarjeta")
                    )
                } else {
                    listaTarjetas
                }
            }
            .navigationTitle("Finanzas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Agregar", systemImage: "plus") {
                        mostrandoCrear = true
                    }
                }
            }
            .sheet(isPresented: $mostrandoCrear) {
                CrearTarjetaView { tarjeta in
                    viewModel.agregar(tarjeta)
                }
            }
            .sheet(item: $tarjetaAEditar) { tarjeta in
                EditarTarjetaView(tarjeta: tarjeta) { actualizada in
                    viewModel.actualizar(actualizada)
                }
            }
            .confirmationDialog(
                "Eliminar «\(tarjetaAEliminar?.nombre ?? "")»",
                isPresented: $mostrandoConfirmacion,
                titleVisibility: .visible
            ) {
                Button("Eliminar", role: .destructive) {
                    if let t = tarjetaAEliminar { viewModel.eliminar(t) }
                    tarjetaAEliminar = nil
                }
            } message: {
                Text("Se eliminarán también todas las compras de esta tarjeta.")
            }
            .navigationDestination(for: TarjetaCredito.self) { tarjeta in
                TarjetaDetailView(tarjeta: tarjeta, viewModel: viewModel)
            }
        }
    }

    // MARK: — Lista

    private var listaTarjetas: some View {
        List {
            Section {
                ResumenDeudaRow(deudaGlobal: viewModel.deudaGlobal)
            }

            if viewModel.datosGraficaDeuda.count > 1 {
                graficaDeuda
            }

            Section("Mis tarjetas") {
                ForEach(viewModel.tarjetas) { tarjeta in
                    ZStack(alignment: .leading) {
                        NavigationLink(value: tarjeta) { EmptyView() }.opacity(0)
                        TarjetaCard(
                            tarjeta: tarjeta,
                            deudaTotal: viewModel.deudaTotal(de: tarjeta),
                            cuotaMes: viewModel.cuotaMes(de: tarjeta),
                            cupoDisponible: viewModel.cupoDisponible(de: tarjeta)
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(
                        top: Spacing.sm,
                        leading: Spacing.md,
                        bottom: Spacing.sm,
                        trailing: Spacing.md
                    ))
                    .swipeActions(edge: .leading) {
                        Button { tarjetaAEditar = tarjeta } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            tarjetaAEliminar = tarjeta
                            mostrandoConfirmacion = true
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: — Gráfica de deuda

extension FinanzasView {
    fileprivate var graficaDeuda: some View {
        Section("Distribución de deuda") {
            VStack(spacing: Spacing.md) {
                Chart(viewModel.datosGraficaDeuda) { dato in
                    SectorMark(
                        angle: .value("Deuda", dato.deuda),
                        innerRadius: .ratio(0.58),
                        angularInset: 2
                    )
                    .foregroundStyle(Color(hex: dato.colorHex))
                    .cornerRadius(4)
                }
                .frame(height: 180)

                VStack(spacing: Spacing.xs) {
                    ForEach(viewModel.datosGraficaDeuda) { dato in
                        HStack(spacing: Spacing.sm) {
                            Circle()
                                .fill(Color(hex: dato.colorHex))
                                .frame(width: 10, height: 10)
                            Text(dato.nombre)
                                .font(.appCaption)
                            Spacer()
                            Text(dato.deuda.moneda)
                                .font(.appCaption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .padding(.vertical, Spacing.xs)
        }
    }
}

// MARK: — Resumen global

private struct ResumenDeudaRow: View {
    let deudaGlobal: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Deuda total")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                Text(deudaGlobal.moneda)
                    .font(.appPoints)
                    .foregroundStyle(deudaGlobal > 0 ? Color.appNegative : Color.appPositive)
                    .contentTransition(.numericText())
                    .animation(AppAnimation.standard, value: deudaGlobal)
            }
            Spacer()
            Image(systemName: "creditcard.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.appAccent)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Tarjeta visual

private struct TarjetaCard: View {
    let tarjeta: TarjetaCredito
    let deudaTotal: Double
    let cuotaMes: Double
    let cupoDisponible: Double

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color(hex: tarjeta.colorHex).gradient)
                .frame(height: 160)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(tarjeta.nombre)
                        .font(.appTitle)
                        .foregroundStyle(.white)
                    Text(tarjeta.banco)
                        .font(.appCaption)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Deuda total")
                            .font(.appCaption)
                            .foregroundStyle(.white.opacity(0.75))
                        Text(deudaTotal.moneda)
                            .font(.appHeadline)
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Cuota próx. mes")
                            .font(.appCaption)
                            .foregroundStyle(.white.opacity(0.75))
                        Text(cuotaMes.moneda)
                            .font(.appHeadline)
                            .foregroundStyle(.white)
                    }
                }

                Text("Cupo disponible: \(cupoDisponible.moneda)")
                    .font(.appCaption)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(Spacing.md)
        }
    }
}

// MARK: — Preview

#Preview {
    FinanzasView()
}
