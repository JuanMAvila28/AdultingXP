import SwiftUI

struct RootView: View {
    @AppStorage(UserSettings.Keys.onboardingMostrado) private var onboardingMostrado = false

    var body: some View {
        TabView {
            ResumenView()
                .tabItem { Label("Resumen", systemImage: "house") }
            HabitosView()
                .tabItem { Label("Hábitos", systemImage: "checkmark.circle") }
            WishlistView()
                .tabItem { Label("Wishlist", systemImage: "gift") }
            TareasView()
                .tabItem { Label("Tareas", systemImage: "graduationcap") }
            PomodoroView()
                .tabItem { Label("Pomodoro", systemImage: "timer") }
            TiempoPantallaView()
                .tabItem { Label("Pantalla", systemImage: "eye") }
            FinanzasView()
                .tabItem { Label("Finanzas", systemImage: "creditcard") }
        }
        .fullScreenCover(isPresented: .constant(!onboardingMostrado)) {
            OnboardingView {
                onboardingMostrado = true
            }
        }
    }
}

#Preview {
    RootView()
}
