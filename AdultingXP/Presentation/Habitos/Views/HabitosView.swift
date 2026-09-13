import SwiftUI

struct HabitosView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Hábitos",
                systemImage: "checkmark.circle",
                description: Text("Aquí rastrearás tus hábitos y ganarás puntos")
            )
            .navigationTitle("Hábitos")
        }
    }
}

#Preview {
    HabitosView()
}
