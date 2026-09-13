import SwiftUI

struct CrearHabitoView: View {
    let onGuardar: (Habito) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var emoji = ""
    @State private var categoria = ""
    @State private var esBueno = true
    @State private var puntajeBase = 10
    @State private var frecuencia: FrecuenciaHabito = .diario

    @State private var nombreDirty = false

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
            .navigationTitle("Nuevo hábito")
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
                    .onChange(of: nombre) { _, _ in nombreDirty = true }
            }

            if nombreDirty && !nombreValido {
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
        let habito = Habito(
            nombre: nombre.trimmingCharacters(in: .whitespaces),
            emoji: emoji,
            categoria: cat.isEmpty ? "General" : cat,
            esBueno: esBueno,
            puntajeBase: puntajeBase,
            frecuencia: frecuencia
        )
        onGuardar(habito)
        dismiss()
    }
}

#Preview {
    CrearHabitoView { _ in }
}
