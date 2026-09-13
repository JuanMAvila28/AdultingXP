import SwiftUI

struct WishlistView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Wishlist",
                systemImage: "gift",
                description: Text("Aquí canjearás tus puntos por recompensas")
            )
            .navigationTitle("Wishlist")
        }
    }
}

#Preview {
    WishlistView()
}
