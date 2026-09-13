import Foundation

/// Preferencias del usuario persistidas en UserDefaults.
/// Usar UserSettings.Keys para que la clave sea consistente entre ViewModel y @AppStorage.
enum UserSettings {

    enum Keys {
        static let diaCorteSemanal  = "diaCorteSemanal"
        static let tasaCambio       = "tasaCambio"
        static let recordatorioOn   = "recordatorioOn"
        static let recordatorioHora = "recordatorioHora"
        static let recordatorioMin  = "recordatorioMin"
    }

    /// Día de la semana en que se reinicia el período semanal.
    /// Usa la convención de Calendar: 1 = domingo, 2 = lunes … 7 = sábado.
    /// Valor por defecto: 2 (lunes).
    static var diaCorteSemanal: Int {
        get { UserDefaults.standard.object(forKey: Keys.diaCorteSemanal) as? Int ?? 2 }
        set { UserDefaults.standard.set(newValue, forKey: Keys.diaCorteSemanal) }
    }

    /// Cuántos pesos equivale 1 punto. Valor por defecto: 100.
    static var tasaCambio: Double {
        get { UserDefaults.standard.object(forKey: Keys.tasaCambio) as? Double ?? 100 }
        set { UserDefaults.standard.set(newValue, forKey: Keys.tasaCambio) }
    }
}
