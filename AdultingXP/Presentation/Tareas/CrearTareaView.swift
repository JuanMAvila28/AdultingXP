import SwiftUI

struct CrearTareaView: View {
    let onGuardar: (Tarea) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var titulo = ""
    @State private var materia = ""
    @State private var fechaLimite = Date.now.addingTimeInterval(86_400 * 3)
    @State private var puntajeBase = 10

    private var formularioValido: Bool {
        !titulo.trimmingCharacters(in: .whitespaces).isEmpty &&
        !materia.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Título de la tarea", text: $titulo)
                    TextField("Materia", text: $materia)
                }

                Section {
                    DatePicker(
                        "Fecha límite",
                        selection: $fechaLimite,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                } footer: {
                    Text("Completar antes de esta fecha suma puntos. Completar después los resta.")
                }

                Section {
                    Stepper("**\(puntajeBase)** pts", value: $puntajeBase, in: 1...50)
                } header: {
                    Text("Puntos en juego")
                }
            }
            .navigationTitle("Nueva tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onGuardar(Tarea(
                            titulo: titulo.trimmingCharacters(in: .whitespaces),
                            materia: materia.trimmingCharacters(in: .whitespaces),
                            fechaLimite: fechaLimite,
                            puntajeBase: puntajeBase
                        ))
                        dismiss()
                    }
                    .disabled(!formularioValido)
                }
            }
        }
    }
}

#Preview {
    CrearTareaView { _ in }
}
