import SwiftUI

struct RootView: View {
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
            FinanzasView()
                .tabItem { Label("Finanzas", systemImage: "creditcard") }
        }
    }
}

#Preview {
    RootView()
}
