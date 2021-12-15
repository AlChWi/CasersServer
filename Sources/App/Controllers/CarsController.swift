import Fluent
import Vapor

struct CarsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let cars = routes.grouped("api", "cars")
        let tokenRoutes = cars.grouped(
            Token.authenticator(),
            User.guardMiddleware()
        )
        tokenRoutes.get(use: getAll(request:))
        tokenRoutes.get(":carID", use: getCar(request:))
        tokenRoutes.delete(":carID", "depart", use: removeCar(request:))
    }
    
    private func getAll(request: Request) async throws -> [Car] {
        let cars = try await Car.query(on: request.db)
            .with(\.$trailer)
            .with(\.$driver)
            .all()
        for car in cars {
            try await car.$sealedCargo.load(on: request.db)
            try await car.trailer?.$sealedCargo.load(on: request.db)
        }
        return cars
    }
    
    private func getCar(request: Request) async throws -> Car {
        guard let id = request.parameters.get("carID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        do {
            let car = try await Car.query(on: request.db)
                .filter(\.$id == id)
                .with(\.$driver)
                .with(\.$trailer)
                .first()
            guard let car = car else {
                throw Abort(.notFound)
            }
            try await car.$sealedCargo.load(on: request.db)
            try await car.trailer?.$sealedCargo.load(on: request.db)
            return car
        } catch {
            throw Abort(.internalServerError)
        }
    }
    
    private func removeCar(request: Request)
    async throws -> HTTPStatus {
        guard let id = request.parameters.get("carID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        do {
            let car = try await Car.query(on: request.db)
                .filter(\.$id == id)
                .first()
            guard let car = car else {
                return .notFound
            }
            try await car.delete(on: request.db)
            return .noContent
        } catch {
            return .internalServerError
        }
    }
}
