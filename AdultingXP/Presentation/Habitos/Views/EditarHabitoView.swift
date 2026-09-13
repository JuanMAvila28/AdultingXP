import SwiftUI

struct EditarHabitoView: View {
    let habito: Habito
    let onGuardar: (Habito) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var nombre: String
    @State private var emoji: String
    @State private var categoria: String
    @State private var esBueno: Bool
    @State private var puntajeBase: Int
    @State private var frecuencia: FrecuenciaHabito

    init(habito: Habito, onGuardar: @escaping (Habito) -> Void) {
        self.habito = habito
        self.onGuardar = onGuardar
        _nombre      = State(initialValue: habito.nombre)
        _emoji       = State(initialValue: habito.emoji)
        _categoria   = State(initialValue: habito.categoria)
        _esBueno     = State(initialValue: habito.esBueno)
        _puntajeBase = State(initialValue: habito.puntajeBase)
        _frecuencia  = State(initialValue: habito.frecuencia)
    }

    private var nombreValido: Bool { !nombre.trimmingCharacters(in: .whitespaces).isEmpty }
    private var emojiValido: Bool  { !emoji.isEmpty }
    private var formularioValido: Bool { nombreValido && emojiValido }

    var body: some View {
        NavigationStack {
            Form {
                seccionIdentidad
                seccionTipo
                seccionPuntaje
            }
            .navigationTitle("Editar hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { guardar() }
                        .disabled(!formularioValido)
                }
            }
        }
    }

    // MARK: — Secciones

    private var seccionIdentidad: some View {
        Section {
            HStack(spacing: Spacing.md) {
                TextField("😀", text: $emoji)
                    .frame(width: 44)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .onChange(of: emoji) { _, newValue in
                        if newValue.count > 1 { emoji = String(newValue.prefix(1)) }
                    }

                Divider()

                TextField("Nombre del hábito", text: $nombre)
            }

            if !nombreValido && !nombre.isEmpty {
                Label("El nombre es obligatorio", systemImage: "exclamationmark.circle.fill")
                    .font(.appCaption)
                    .foregroundStyle(Color.appNegative)
            }

            TextField("Categoría (Salud, Estudio, Hogar…)", text: $categoria)

        } header: {
            Text("Identificación")
        }
    }

    private var seccionTipo: some View {
        Section {
            Toggle(isOn: $esBueno) {
                Label(
                    esBueno ? "Hábito bueno" : "Hábito malo",
                    systemImage: esBueno ? "plus.circle.fill" : "minus.circle.fill"
                )
                .foregroundStyle(esBueno ? Color.appPositive : Color.appNegative)
            }
            .tint(esBueno ? Color.appPositive : Color.appNegative)

        } header: {
            Text("Tipo")
        } footer: {
            Text(esBueno
                 ? "Completarlo suma \(puntajeBase) pts al balance"
                 : "Registrarlo resta \(puntajeBase) pts al balance")
        }
    }

    private var seccionPuntaje: some View {
        Section {
            Stepper("\(puntajeBase) puntos", value: $puntajeBase, in: 1...50)

            Picker("Frecuencia", selection: $frecuencia) {
                ForEach(FrecuenciaHabito.allCases, id: \.self) { f in
                    Text(f.label).tag(f)
                }
            }
            .pickerStyle(.segmented)

        } header: {
            Text("Puntos y frecuencia")
        }
    }

    // MARK: — Acción

    private func guardar() {
        let cat = categoria.trimmingCharacters(in: .whitespaces)
        let actualizado = Habito(
            id: habito.id,
            nombre: nombre.trimmingCharacters(in: .whitespaces),
            emoji: emoji,
            categoria: cat.isEmpty ? "General" : cat,
            esBueno: esBueno,
            puntajeBase: puntajeBase,
            frecuencia: frecuencia,
            streakActual: habito.streakActual,
            fechaUltimaCompletacion: habito.fechaUltimaCompletacion
        )
        onGuardar(actualizado)
        dismiss()
    }
}

#Preview {
    EditarHabitoView(
        habito: Habito(nombre: "Hacer ejercicio", emoji: "💪", categoria: "Salud", puntajeBase: 15)
    ) { _ in }
}
