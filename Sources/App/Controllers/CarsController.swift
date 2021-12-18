import Fluent
import Vapor
import Darwin

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
        tokenRoutes.delete(":carID", "remove", ":cargoNumber", use: removeCarCargo(request:))
        tokenRoutes.post(":carID", "add", ":cargoNumber", use: addCarCargo(request:))
        tokenRoutes.post("trailer", ":trailerID", "add", ":cargoNumber", use: addTrailerCargo(request:))
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
    }
    
    private func removeCar(request: Request)
    async throws -> HTTPStatus {
        guard let id = request.parameters.get("carID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let car = try await Car.query(on: request.db)
            .filter(\.$id == id)
            .first()
        guard let car = car else {
            return .notFound
        }
        try await car.delete(on: request.db)
        return .noContent
    }
    
    private func removeCarCargo(request: Request)
    async throws -> HTTPStatus {
        guard let id = request.parameters.get("carID", as: UUID.self),
              let cargoNumber = request.parameters.get("cargoNumber") else {
                  throw Abort(.badRequest)
              }
        let car = try await Car.query(on: request.db)
            .filter(\.$id == id)
            .with(\.$trailer)
            .first()
        guard let car = car else {
            return .notFound
        }
        try await car.$sealedCargo.load(on: request.db)
        try await car.trailer?.$sealedCargo.load(on: request.db)
        try await car.sealedCargo.first {
            $0.number == cargoNumber
        }?.delete(on: request.db)
        try await car.trailer?.sealedCargo.first {
            $0.number == cargoNumber
        }?.delete(on: request.db)
        
        return .noContent
    }
    
    private func addCarCargo(request: Request)
    async throws -> SealedCargo {
        guard let id = request.parameters.get("carID", as: UUID.self),
            let cargoNumber = request.parameters.get("cargoNumber") else {
            throw Abort(.badRequest)
        }
        let cargo = SealedCargo(number: cargoNumber, carID: id, trailerID: nil)
        try await cargo.save(on: request.db)
        
        return cargo
    }
    
    private func addTrailerCargo(request: Request)
    async throws -> SealedCargo {
        guard let id = request.parameters.get("trailerID", as: UUID.self),
            let cargoNumber = request.parameters.get("cargoNumber") else {
            throw Abort(.badRequest)
        }
        let cargo = SealedCargo(number: cargoNumber, carID: nil, trailerID: id)
        try await cargo.save(on: request.db)
        
        return cargo
    }
}
