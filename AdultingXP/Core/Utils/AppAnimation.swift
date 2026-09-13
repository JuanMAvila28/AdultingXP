import SwiftUI

/// Tokens de animación de AdultingXP.
///
/// Regla general:
/// - Usa `standard` para casi todo (menús, sheets, transiciones).
/// - Usa `bouncy` solo cuando el gesto del usuario traía momentum (flick, drag soltado).
/// - Usa `quick` para feedback táctil inmediato (scale-on-press).
enum AppAnimation {

    /// Spring críticamente amortiguado — sin rebote, interrumpible.
    /// Úsalo como default para cualquier cosa que aparezca o cambie de estado.
    static let standard: Animation = .spring(response: 0.35, dampingFraction: 1.0)

    /// Spring con rebote suave — solo para gestos con momentum.
    static let bouncy: Animation = .spring(response: 0.35, dampingFraction: 0.78)

    /// Spring rápido — para el instante en que el dedo toca un elemento interactivo.
    static let quick: Animation = .spring(response: 0.22, dampingFraction: 1.0)
}
