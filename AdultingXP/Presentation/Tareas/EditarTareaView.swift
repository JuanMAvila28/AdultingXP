import SwiftUI

struct EditarTareaView: View {
    let tarea: Tarea
    let onGuardar: (Tarea) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var titulo: String
    @State private var materia: String
    @State private var fechaLimite: Date
    @State private var puntajeBase: Int

    init(tarea: Tarea, onGuardar: @escaping (Tarea) -> Void) {
        self.tarea = tarea
        self.onGuardar = onGuardar
        _titulo = State(initialValue: tarea.titulo)
        _materia = State(initialValue: tarea.materia)
        _fechaLimite = State(initialValue: tarea.fechaLimite)
        _puntajeBase = State(initialValue: tarea.puntajeBase)
    }

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
            .navigationTitle("Editar tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        var actualizada = tarea
                        actualizada.titulo = titulo.trimmingCharacters(in: .whitespaces)
                        actualizada.materia = materia.trimmingCharacters(in: .whitespaces)
                        actualizada.fechaLimite = fechaLimite
                        actualizada.puntajeBase = puntajeBase
                        onGuardar(actualizada)
                        dismiss()
                    }
                    .disabled(!formularioValido)
                }
            }
        }
    }
}

#Preview {
    EditarTareaView(
        tarea: Tarea(
            titulo: "Parcial de Cálculo",
            materia: "Matemáticas",
            fechaLimite: .now.addingTimeInterval(86_400 * 3)
        )
    ) { _ in }
}
