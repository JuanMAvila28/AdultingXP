import SwiftUI

struct TarjetaDetailView: View {
    let tarjeta: TarjetaCredito
    let viewModel: FinanzasViewModel

    @State private var mostrandoAgregarCompra = false
    @State private var mostrandoSimulador = false
    @State private var compraAEliminar: Compra? = nil
    @State private var mostrandoConfirmacion = false

    private var comprasActivas: [Compra] {
        viewModel.compras(de: tarjeta).filter { !$0.estaPagada(diaCorte: tarjeta.diaCorte) }
    }

    private var comprasPagadas: [Compra] {
        viewModel.compras(de: tarjeta).filter { $0.estaPagada(diaCorte: tarjeta.diaCorte) }
    }

    var body: some View {
        List {
            Section {
                TarjetaResumenRow(
                    deudaTotal: viewModel.deudaTotal(de: tarjeta),
                    cuotaMes: viewModel.cuotaMes(de: tarjeta),
                    cupoDisponible: viewModel.cupoDisponible(de: tarjeta),
                    diaCorte: tarjeta.diaCorte,
                    diaPago: tarjeta.diaPago
                )
            }

            if comprasActivas.isEmpty && comprasPagadas.isEmpty {
                Section {
                    ContentUnavailableView(
                        "Sin compras",
                        systemImage: "cart",
                        description: Text("Toca + para registrar una compra")
                    )
                    .listRowBackground(Color.clear)
                }
            }

            if !comprasActivas.isEmpty {
                Section("Compras activas") {
                    ForEach(comprasActivas) { compra in
                        CompraRow(compra: compra, diaCorte: tarjeta.diaCorte)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    compraAEliminar = compra
                                    mostrandoConfirmacion = true
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                    }
                }
            }

            if !comprasPagadas.isEmpty {
                Section("Pagadas") {
                    ForEach(comprasPagadas) { compra in
                        CompraRow(compra: compra, diaCorte: tarjeta.diaCorte)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    compraAEliminar = compra
                                    mostrandoConfirmacion = true
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(tarjeta.nombre)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Simular", systemImage: "wand.and.sparkles") {
                    mostrandoSimulador = true
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Agregar compra", systemImage: "plus") {
                    mostrandoAgregarCompra = true
                }
            }
        }
        .sheet(isPresented: $mostrandoSimulador) {
            SimuladorCompraView(
                tarjeta: tarjeta,
                cuotaMesActual: viewModel.cuotaMes(de: tarjeta),
                deudaActual: viewModel.deudaTotal(de: tarjeta),
                cupoActual: viewModel.cupoDisponible(de: tarjeta)
            )
        }
        .sheet(isPresented: $mostrandoAgregarCompra) {
            AgregarCompraView(tarjetaId: tarjeta.id) { compra in
                viewModel.agregarCompra(compra)
            }
        }
        .confirmationDialog(
            "Eliminar «\(compraAEliminar?.descripcion ?? "")»",
            isPresented: $mostrandoConfirmacion,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                if let compra = compraAEliminar { viewModel.eliminarCompra(compra) }
                compraAEliminar = nil
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
    }
}

// MARK: — Resumen de tarjeta

private struct TarjetaResumenRow: View {
    let deudaTotal: Double
    let cuotaMes: Double
    let cupoDisponible: Double
    let diaCorte: Int
    let diaPago: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Deuda total")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Text(deudaTotal.moneda)
                        .font(.appPoints)
                        .foregroundStyle(deudaTotal > 0 ? Color.appNegative : Color.appPositive)
                        .contentTransition(.numericText())
                        .animation(AppAnimation.standard, value: deudaTotal)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Cuota próx. mes")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Text(cuotaMes.moneda)
                        .font(.appPoints)
                        .foregroundStyle(cuotaMes > 0 ? Color.appNegative : .secondary)
                        .contentTransition(.numericText())
                        .animation(AppAnimation.standard, value: cuotaMes)
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Cupo disponible")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Text(cupoDisponible.moneda)
                        .font(.appHeadline)
                        .foregroundStyle(cupoDisponible > 0 ? Color.appPositive : Color.appNegative)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Corte · Pago")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Text("Día \(diaCorte) · Día \(diaPago)")
                        .font(.appHeadline)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Fila de compra

private struct CompraRow: View {
    let compra: Compra
    let diaCorte: Int

    var body: some View {
        let billeadas = compra.cuotasBilled(diaCorte: diaCorte)
        let restantes = compra.cuotasRestantes(diaCorte: diaCorte)
        let pagada = compra.estaPagada(diaCorte: diaCorte)

        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(compra.descripcion)
                    .font(.appHeadline)
                    .strikethrough(pagada)
                    .foregroundStyle(pagada ? .secondary : .primary)
                Spacer()
                if !pagada {
                    Text(compra.montoPorCuota.moneda)
                        .font(.appHeadline)
                        .foregroundStyle(Color.appNegative)
                }
            }

            if pagada {
                Text("Pagada · \(compra.montoTotal.moneda) total")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(billeadas) de \(compra.numeroCuotas) cuotas · \(compra.saldoPendiente(diaCorte: diaCorte).moneda) restantes")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }

            if !pagada && compra.numeroCuotas > 1 {
                ProgressView(value: Double(billeadas), total: Double(compra.numeroCuotas))
                    .tint(Color.appAccent)
                    .animation(AppAnimation.standard, value: billeadas)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: — Preview

#Preview {
    NavigationStack {
        TarjetaDetailView(
            tarjeta: TarjetaCredito(
                nombre: "Visa Preferencia",
                banco: "Bancolombia",
                limiteCredito: 10_000_000,
                diaCorte: 20,
                diaPago: 10
            ),
            viewModel: FinanzasViewModel()
        )
    }
}
