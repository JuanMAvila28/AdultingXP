import Foundation

struct RegistrarTiempoPantallaUseCase {
    private let pantallaRepo: any RegistroTiempoPantallaRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol

    init(
        pantallaRepo: any RegistroTiempoPantallaRepositoryProtocol = RegistroTiempoPantallaRepository(),
        registroRepo: any RegistroPuntosRepositoryProtocol = RegistroPuntosRepository()
    ) {
        self.pantallaRepo = pantallaRepo
        self.registroRepo = registroRepo
    }

    struct Resultado {
        let registroActualizado: RegistroTiempoPantalla
        let nuevoRegistroPuntos: RegistroPuntos
    }

    func ejecutar(
        minutosUsados: Int,
        registrosExistentes: [RegistroTiempoPantalla],
        registrosPuntos: [RegistroPuntos],
        limite: Int,
        puntosCumplimiento: Int,
        penalizacion: Int
    ) -> Resultado {
        let inicioSemana = Self.inicioSemanaActual()
        let existente = registrosExistentes.first {
            Self.misma(semana: $0.semana, que: inicioSemana)
        }

        let cumple = minutosUsados <= limite
        let nuevaCantidad = cumple ? puntosCumplimiento : -penalizacion

        var puntosActualizados = registrosPuntos

        // Compensar puntos anteriores si ya había un registro esta semana
        if let previo = existente {
            let compensacion = RegistroPuntos(
                cantidad: -previo.puntosOtorgados,
                concepto: "↩ Corrección tiempo de pantalla",
                origen: .tiempoPantalla
            )
            puntosActualizados.append(compensacion)
        }

        let nuevoRegistroPuntos = RegistroPuntos(
            cantidad: nuevaCantidad,
            concepto: cumple ? "📵 Límite de pantalla cumplido" : "📱 Límite de pantalla excedido",
            origen: .tiempoPantalla
        )
        puntosActualizados.append(nuevoRegistroPuntos)
        registroRepo.guardar(puntosActualizados)

        let registroActualizado = RegistroTiempoPantalla(
            id: existente?.id ?? UUID(),
            semana: inicioSemana,
            minutosUsados: minutosUsados,
            minutosLimite: limite,
            puntosOtorgados: nuevaCantidad
        )

        var todos = registrosExistentes
        if let i = todos.firstIndex(where: { Self.misma(semana: $0.semana, que: inicioSemana) }) {
            todos[i] = registroActualizado
        } else {
            todos.append(registroActualizado)
        }
        pantallaRepo.guardar(todos)

        return Resultado(registroActualizado: registroActualizado, nuevoRegistroPuntos: nuevoRegistroPuntos)
    }

    static func inicioSemanaActual() -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let c = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)
        return cal.date(from: c) ?? .now
    }

    private static func misma(semana a: Date, que b: Date) -> Bool {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal.isDate(a, equalTo: b, toGranularity: .weekOfYear)
    }
}
