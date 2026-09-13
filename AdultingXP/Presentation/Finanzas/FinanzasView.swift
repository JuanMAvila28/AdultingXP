import SwiftUI

struct FinanzasView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Finanzas",
                systemImage: "creditcard",
                description: Text("Aquí gestionarás tus tarjetas de crédito")
            )
            .navigationTitle("Finanzas")
        }
    }
}

#Preview {
    FinanzasView()
}
