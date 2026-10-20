import SwiftUI

struct TiempoTranscurridoText: View {
    let fecha: Date
    private let formatter = TiempoTranscurridoFormatter()

    var body: some View {
        TimelineView(.everyMinute) { _ in
            Text(formatter.formatear(fecha))
        }
    }
}

#Preview("Edge cases") {
    let f = TiempoTranscurridoFormatter()
    let ahora = Date.now

    return List {
        row("30 seg",   f.formatear(ahora - 30))
        row("59 seg",   f.formatear(ahora - 59))
        row("1 min",    f.formatear(ahora - 60))
        row("23 min",   f.formatear(ahora - 23 * 60))
        row("59 min",   f.formatear(ahora - 59 * 60))
        row("1 h",      f.formatear(ahora - 3_600))
        row("23 h",     f.formatear(ahora - 23 * 3_600))
        row("1 día",    f.formatear(ahora - 86_400))
        row("6 días",   f.formatear(ahora - 6 * 86_400))
        row("1 sem",    f.formatear(ahora - 7 * 86_400))
        row("3 sem",    f.formatear(ahora - 21 * 86_400))
        row("1 mes",    f.formatear(ahora - 30 * 86_400))
        row("3 meses",  f.formatear(ahora - 90 * 86_400))
    }
}

private func row(_ label: String, _ resultado: String) -> some View {
    HStack {
        Text(label).foregroundStyle(.secondary)
        Spacer()
        Text(resultado).bold()
    }
}
