import SwiftUI

struct TareasView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Tareas",
                systemImage: "graduationcap",
                description: Text("Aquí gestionarás tus tareas universitarias")
            )
            .navigationTitle("Tareas")
        }
    }
}

#Preview {
    TareasView()
}
