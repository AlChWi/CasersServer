import Vapor
import Fluent
import Crypto
import Foundation

final class UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoutes = routes.grouped("api", "users")
        
        let authenticatedRoutes = usersRoutes.grouped(
            User.authenticator(),
            User.guardMiddleware()
        )
        authenticatedRoutes.post("login", use: loginHandler(_:))
    }
    
    private func loginHandler(_ req: Request)
    async throws -> Token.DTO {
        let user = try req.auth.require(User.self)
        let token = try Token.generate(for: user)
        do {
            try await token.save(on: req.db)
            let userID = try user.requireID()
            return Token.DTO(value: token.value, userID: userID)
        } catch {
            throw Abort(.badRequest)
        }
    }
}
