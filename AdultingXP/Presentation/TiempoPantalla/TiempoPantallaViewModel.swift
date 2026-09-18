import Foundation
import Observation

@Observable
final class TiempoPantallaViewModel {
    private let pantallaRepo: any RegistroTiempoPantallaRepositoryProtocol
    private let registroRepo: any RegistroPuntosRepositoryProtocol
    private let registrarUseCase: RegistrarTiempoPantallaUseCase

    var registros: [RegistroTiempoPantalla] = []
    var registrosPuntos: [RegistroPuntos] = []
    var minutosIngresados: Int = 0
    var guardadoExitoso = false

    init(
        pantallaRepo: any RegistroTiempoPantallaRepositoryProtocol = RegistroTiempoPantallaRepository(),
        registroRepo: any RegistroPuntosRepositoryProtocol = RegistroPuntosRepository()
    ) {
        self.pantallaRepo = pantallaRepo
        self.registroRepo = registroRepo
        self.registrarUseCase = RegistrarTiempoPantallaUseCase(
            pantallaRepo: pantallaRepo,
            registroRepo: registroRepo
        )
        cargar()
    }

    private func cargar() {
        registros = pantallaRepo.cargar()
        registrosPuntos = registroRepo.cargar()
        if let actual = registroSemanaActual {
            minutosIngresados = actual.minutosUsados
        }
    }

    var balanceGlobal: Int { registrosPuntos.reduce(0) { $0 + $1.cantidad } }

    var registroSemanaActual: RegistroTiempoPantalla? {
        let inicio = RegistrarTiempoPantallaUseCase.inicioSemanaActual()
        var cal = Calendar.current
        cal.firstWeekday = 2
        return registros.first { cal.isDate($0.semana, equalTo: inicio, toGranularity: .weekOfYear) }
    }

    var registrosOrdenados: [RegistroTiempoPantalla] {
        registros.sorted { $0.semana > $1.semana }
    }

    func registrar(limite: Int, puntos: Int, penalizacion: Int) {
        let _ = registrarUseCase.ejecutar(
            minutosUsados: minutosIngresados,
            registrosExistentes: registros,
            registrosPuntos: registrosPuntos,
            limite: limite,
            puntosCumplimiento: puntos,
            penalizacion: penalizacion
        )
        registros = pantallaRepo.cargar()
        registrosPuntos = registroRepo.cargar()
        guardadoExitoso.toggle()
    }
}
