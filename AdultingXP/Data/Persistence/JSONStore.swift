import Foundation

/// Utilidad genérica de persistencia: guarda y carga cualquier valor Codable
/// como JSON en el directorio Documents del sandbox de la app.
///
/// Etapa 1 — el ViewModel la usa directamente.
/// Etapa 2 (CH-1.7) — esta lógica quedará encapsulada en los repositorios concretos.
enum JSONStore {

    // MARK: — Guardar

    static func save<T: Codable>(_ value: T, toFile filename: String) {
        do {
            let url = try documentURL(for: filename)
            let data = try JSONEncoder().encode(value)
            // .atomicWrite escribe primero en un archivo temporal y luego hace swap.
            // Garantiza que nunca queda un archivo corrupto si la app se cierra a mitad.
            try data.write(to: url, options: .atomicWrite)
        } catch {
            print("[JSONStore] Error al guardar \(filename): \(error)")
        }
    }

    // MARK: — Cargar

    static func load<T: Codable>(_ type: T.Type, fromFile filename: String) -> T? {
        guard
            let url = try? documentURL(for: filename),
            let data = try? Data(contentsOf: url)
        else { return nil }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("[JSONStore] Error al decodificar \(filename): \(error)")
            return nil
        }
    }

    // MARK: — Privado

    private static func documentURL(for filename: String) throws -> URL {
        try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(filename)
    }
}
