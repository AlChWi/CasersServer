import Vapor
import Fluent

final class User: Model {
    static var schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    @Field(key: "username")
    var username: String
    @Field(key: "password")
    var passwordHash: String
    
    init() {}
    
    init(
        id: UUID? = nil,
        name: String,
        username: String,
        passwordHash: String
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.passwordHash = passwordHash
    }
    
    func convertToPublic() -> Public {
        User.Public(
            id: id,
            name: name,
            username: username
        )
    }
}

extension User {
    struct RegisterData: Content {
        let name: String
        let username: String
        let password: String
    }
}

extension User.RegisterData: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .ascii, required: true)
        validations.add("username", as: String.self, is: .alphanumeric && .count(3...), required: true)
        validations.add("password", as: String.self, is: .count(8...), required: true)
    }
}

extension User {
    final class Public: Content {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$username
    static var passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: passwordHash)
    }
}

extension User: CredentialsAuthenticator {
    typealias Credentials = CredentialsInput
    
    struct CredentialsInput: Content {
        let username: String
        let password: String
    }
    
    func authenticate(credentials: Credentials, for request: Request) -> EventLoopFuture<Void> {
        User.query(on: request.db)
            .filter(\.$username == credentials.username)
            .first()
            .map { user in
                if let user = user,
                   let passwordCheck = try? Bcrypt.verify(credentials.password, created: user.passwordHash),
                   passwordCheck {
                    request.auth.login(user)
                }
            }
    }
}

extension User: SessionAuthenticatable {
    typealias SessionID = UUID
    
    var sessionID: UUID { self.id! }
}

extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        self.map { $0.convertToPublic() }
    }
}
