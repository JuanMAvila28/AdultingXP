import SwiftUI

struct OnboardingView: View {
    let onCompletar: () -> Void

    @State private var paginaActual = 0

    private let paginas: [PaginaOnboarding] = [
        PaginaOnboarding(
            icono: "star.circle.fill",
            color: .appAccent,
            titulo: "Bienvenido a AdultingXP",
            descripcion: "Convierte tus hábitos y tareas universitarias en puntos que puedes canjear por recompensas reales."
        ),
        PaginaOnboarding(
            icono: "checkmark.circle.fill",
            color: .appPositive,
            titulo: "Gana puntos",
            descripcion: "Completa hábitos cada día y entrega tareas a tiempo. Las rachas largas dan puntos extra."
        ),
        PaginaOnboarding(
            icono: "gift.fill",
            color: .purple,
            titulo: "Canjea recompensas",
            descripcion: "Define lo que quieres en tu Wishlist y úsala como meta. Cuando tengas los puntos, reclama tu recompensa."
        ),
        PaginaOnboarding(
            icono: "creditcard.fill",
            color: .blue,
            titulo: "Controla tus finanzas",
            descripcion: "Registra tus tarjetas y compras en cuotas. La app calcula automáticamente cuánto debes cada mes."
        )
    ]

    private var esUltimaPagina: Bool { paginaActual == paginas.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $paginaActual) {
                ForEach(paginas.indices, id: \.self) { i in
                    PaginaView(pagina: paginas[i])
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(AppAnimation.standard, value: paginaActual)

            Button {
                if esUltimaPagina {
                    onCompletar()
                } else {
                    withAnimation(AppAnimation.standard) { paginaActual += 1 }
                }
            } label: {
                Text(esUltimaPagina ? "Empezar" : "Continuar")
                    .font(.appHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
            .animation(AppAnimation.standard, value: esUltimaPagina)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: — Modelo

private struct PaginaOnboarding {
    let icono: String
    let color: Color
    let titulo: String
    let descripcion: String
}

// MARK: — Página individual

private struct PaginaView: View {
    let pagina: PaginaOnboarding

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: pagina.icono)
                .font(.system(size: 80))
                .foregroundStyle(pagina.color)
                .symbolEffect(.bounce, value: pagina.icono)

            VStack(spacing: Spacing.md) {
                Text(pagina.titulo)
                    .font(.appTitle)
                    .multilineTextAlignment(.center)

                Text(pagina.descripcion)
                    .font(.appBody)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: — Preview

#Preview {
    OnboardingView { }
}
