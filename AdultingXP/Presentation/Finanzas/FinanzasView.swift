import SwiftUI

struct FinanzasView: View {
    @State private var viewModel = FinanzasViewModel()
    @State private var mostrandoCrear = false
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
        }
    }

    // MARK: — Lista

    private var listaTarjetas: some View {
        List {
            Section {
                ResumenDeudaRow(deudaGlobal: viewModel.deudaGlobal)
            }

            Section("Mis tarjetas") {
                ForEach(viewModel.tarjetas) { tarjeta in
                    TarjetaCard(
                        tarjeta: tarjeta,
                        deudaTotal: viewModel.deudaTotal(de: tarjeta),
                        cuotaMes: viewModel.cuotaMes(de: tarjeta),
                        cupoDisponible: viewModel.cupoDisponible(de: tarjeta)
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(
                        top: Spacing.sm,
                        leading: Spacing.md,
                        bottom: Spacing.sm,
                        trailing: Spacing.md
                    ))
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
