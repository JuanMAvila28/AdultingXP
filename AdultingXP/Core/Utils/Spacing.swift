import CoreFoundation

/// Escala de espaciado basada en múltiplos de 4 pt (grid de 4 pt de iOS).
enum Spacing {
    static let xs: CGFloat  =  4   // ícono ↔ etiqueta
    static let sm: CGFloat  =  8   // entre elementos relacionados
    static let md: CGFloat  = 16   // padding estándar de contenido
    static let lg: CGFloat  = 24   // separación entre secciones
    static let xl: CGFloat  = 32   // secciones principales
    static let xxl: CGFloat = 48   // áreas hero / balance destacado
}

/// Radios de esquina consistentes con el lenguaje visual de iOS.
enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}
