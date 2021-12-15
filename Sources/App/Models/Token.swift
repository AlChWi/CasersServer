import Vapor
import Fluent

final class Token: Model {
    static var schema = "tokens"
    
    @ID
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    @Parent(key: "userID")
    var user: User
    
    init() {}
    
    init(
        id: UUID? = nil,
        value: String,
        userID: User.IDValue
    ) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
    
    static func generate(for user: User) throws -> Token {
        return try Token(
            value: [UInt8].random(count: 16).base64.replacingOccurrences(of: "/", with: "a"),
            userID: user.requireID()
        )
    }
}

extension Token {
    struct DTO: Content {
        let value: String
        let userID: UUID
    }
}

extension Token: ModelTokenAuthenticatable {
    static var valueKey = \Token.$value
    static var userKey = \Token.$user
    
    var isValid: Bool {
        return true
    }
}
