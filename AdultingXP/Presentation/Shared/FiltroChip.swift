import SwiftUI

struct FiltroChip: View {
    let titulo: String
    let seleccionado: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(titulo)
                .font(.appCaption)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(seleccionado ? Color.appAccent : Color.secondary.opacity(0.12))
                .foregroundStyle(seleccionado ? Color.white : Color.primary)
                .clipShape(Capsule())
                .animation(AppAnimation.quick, value: seleccionado)
        }
        .buttonStyle(.plain)
    }
}
