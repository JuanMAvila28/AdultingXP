import SwiftUI

struct TarjetaDetailView: View {
    let tarjeta: TarjetaCredito
    let viewModel: FinanzasViewModel

    @State private var mostrandoAgregarCompra = false
    @State private var mostrandoSimulador = false
    @State private var mostrandoRegistrarPago = false
    @State private var compraAEditar: Compra? = nil
    @State private var compraAEliminar: Compra? = nil
    @State private var pagoAEliminar: Pago? = nil
    @State private var mostrandoConfirmacionCompra = false
    @State private var mostrandoConfirmacionPago = false

    private var comprasActivas: [Compra] {
        viewModel.compras(de: tarjeta).filter { !$0.estaPagada(diaCorte: tarjeta.diaCorte) }
    }

    private var comprasPagadas: [Compra] {
        viewModel.compras(de: tarjeta).filter { $0.estaPagada(diaCorte: tarjeta.diaCorte) }
    }

    private var historialPagos: [Pago] {
        viewModel.pagos(de: tarjeta).reversed()
    }

    var body: some View {
        List {
            Section {
                TarjetaResumenRow(
                    deudaTotal: viewModel.deudaTotal(de: tarjeta),
                    cuotaMes: viewModel.cuotaMes(de: tarjeta),
                    cuotaManejo: tarjeta.cuotaManejo ?? 0,
                    saldoAnterior: viewModel.saldoAnterior(de: tarjeta),
                    valorAPagar: viewModel.valorAPagar(de: tarjeta),
                    cupoDisponible: viewModel.cupoDisponible(de: tarjeta),
                    diaCorte: tarjeta.diaCorte,
                    diaPago: tarjeta.diaPago,
                    ultimoPago: historialPagos.first
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

            let forecast = viewModel.forecastMensual(de: tarjeta)
            if forecast.contains(where: { $0.total > 0 }) {
                Section("Próximos meses") {
                    ForEach(forecast) { pago in
                        HStack {
                            Text(pago.mes, format: .dateTime.month(.wide).year()
                                .locale(Locale(identifier: "es_CO")))
                                .font(.appBody)
                                .textCase(nil)
                            Spacer()
                            Text(pago.total > 0 ? pago.total.moneda : "—")
                                .font(.appHeadline)
                                .foregroundStyle(pago.total > 0 ? Color.appNegative : .secondary)
                                .monospacedDigit()
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            if !comprasActivas.isEmpty {
                Section("Compras activas") {
                    ForEach(comprasActivas) { compra in
                        CompraRow(compra: compra, diaCorte: tarjeta.diaCorte)
                            .swipeActions(edge: .leading) {
                                Button { compraAEditar = compra } label: {
                                    Label("Editar", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    compraAEliminar = compra
                                    mostrandoConfirmacionCompra = true
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
                                    mostrandoConfirmacionCompra = true
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                    }
                }
            }

            if !historialPagos.isEmpty {
                Section("Historial de pagos") {
                    ForEach(historialPagos) { pago in
                        PagoRow(pago: pago)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    pagoAEliminar = pago
                                    mostrandoConfirmacionPago = true
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
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Registrar pago", systemImage: "banknote") {
                    mostrandoRegistrarPago = true
                }
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
        .sheet(isPresented: $mostrandoRegistrarPago) {
            RegistrarPagoView(
                tarjeta: tarjeta,
                valorAPagar: viewModel.valorAPagar(de: tarjeta)
            ) { pago in
                viewModel.agregarPago(pago)
            }
        }
        .sheet(isPresented: $mostrandoAgregarCompra) {
            AgregarCompraView(tarjetaId: tarjeta.id) { compra in
                viewModel.agregarCompra(compra)
            }
        }
        .sheet(item: $compraAEditar) { compra in
            EditarCompraView(compra: compra) { actualizada in
                viewModel.actualizarCompra(actualizada)
            }
        }
        .confirmationDialog(
            "Eliminar «\(compraAEliminar?.descripcion ?? "")»",
            isPresented: $mostrandoConfirmacionCompra,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                if let compra = compraAEliminar { viewModel.eliminarCompra(compra) }
                compraAEliminar = nil
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .confirmationDialog(
            "Eliminar pago",
            isPresented: $mostrandoConfirmacionPago,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                if let pago = pagoAEliminar { viewModel.eliminarPago(pago) }
                pagoAEliminar = nil
            }
        } message: {
            Text("El saldo anterior se recalculará automáticamente.")
        }
    }
}

// MARK: — Resumen de tarjeta

private struct TarjetaResumenRow: View {
    let deudaTotal: Double
    let cuotaMes: Double
    let cuotaManejo: Double
    let saldoAnterior: Double
    let valorAPagar: Double
    let cupoDisponible: Double
    let diaCorte: Int
    let diaPago: Int
    let ultimoPago: Pago?

    private var tieneComponentesExtra: Bool {
        cuotaManejo > 0 || saldoAnterior > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Total a pagar")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Text(valorAPagar.moneda)
                        .font(.appPoints)
                        .foregroundStyle(valorAPagar > 0 ? Color.appNegative : Color.appPositive)
                        .contentTransition(.numericText())
                        .animation(AppAnimation.standard, value: valorAPagar)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Deuda total")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Text(deudaTotal.moneda)
                        .font(.appPoints)
                        .foregroundStyle(deudaTotal > 0 ? Color.appNegative : Color.appPositive)
                        .contentTransition(.numericText())
                        .animation(AppAnimation.standard, value: deudaTotal)
                }
            }

            if tieneComponentesExtra {
                desglose
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

            if let pago = ultimoPago {
                Divider()
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appPositive)
                        .font(.appCaption)
                    Text("Último pago: \(pago.montoPagado.moneda)")
                        .font(.appCaption)
                        .foregroundStyle(Color.appPositive)
                    Spacer()
                    Text(pago.fechaPago.etiquetaDia)
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private var desglose: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            desgloseRow("Cuotas del mes", cuotaMes)
            if cuotaManejo > 0 {
                desgloseRow("Cuota de manejo", cuotaManejo)
            }
            if saldoAnterior > 0 {
                desgloseRow("Saldo anterior", saldoAnterior)
                    .foregroundStyle(Color.appWarning)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }

    private func desgloseRow(_ label: String, _ valor: Double) -> some View {
        HStack {
            Text(label)
                .font(.appCaption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(valor.moneda)
                .font(.appCaption.monospacedDigit())
        }
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
                if compra.tieneInteres {
                    Image(systemName: "percent")
                        .font(.appCaption)
                        .foregroundStyle(Color.appWarning)
                }
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

// MARK: — Fila de pago

private struct PagoRow: View {
    let pago: Pago

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(pago.montoPagado.moneda)
                    .font(.appHeadline)
                    .foregroundStyle(Color.appPositive)
                Text(pago.fechaPago.etiquetaDia)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if pago.balanceAntes > pago.montoPagado {
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Saldo no pagado")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                    Text((pago.balanceAntes - pago.montoPagado).moneda)
                        .font(.appCaption.monospacedDigit())
                        .foregroundStyle(Color.appWarning)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.appPositive)
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
                diaPago: 10,
                cuotaManejo: 18_900
            ),
            viewModel: FinanzasViewModel()
        )
    }
}
