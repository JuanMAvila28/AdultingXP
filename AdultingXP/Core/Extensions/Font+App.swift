import SwiftUI

extension Font {

    // MARK: — Escala tipográfica de AdultingXP
    //
    // Todas las variantes respetan Dynamic Type: usan los estilos semánticos
    // del sistema en lugar de tamaños fijos, por lo que escalan automáticamente
    // cuando el usuario cambia el tamaño de texto en Ajustes.

    /// Balance global de puntos y cifras protagonistas. Rounded da sensación de juego.
    static let appDisplay: Font = .system(.largeTitle, design: .rounded, weight: .bold)

    /// Números de puntos en celdas y totales por tarjeta.
    static let appPoints: Font = .system(.title2, design: .rounded, weight: .bold)

    /// Títulos de pantalla dentro de NavigationStack.
    static let appTitle: Font = .system(.title2, design: .default, weight: .semibold)

    /// Nombre de hábito, ítem de wishlist, tarea o tarjeta.
    static let appHeadline: Font = .headline

    /// Cuerpo de descripción, contenido principal de formularios.
    static let appBody: Font = .body

    /// Fechas, categorías, metadatos secundarios.
    static let appSubheadline: Font = .subheadline

    /// Etiquetas pequeñas, badges, pie de celda.
    static let appCaption: Font = .caption.weight(.medium)
}
