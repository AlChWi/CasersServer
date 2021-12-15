import Fluent
import Vapor

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .field("password", .string, .required)
            .unique(on: "username")
            .create()
            .flatMap {
                let passwordHash: String
                do {
                    passwordHash = try Bcrypt.hash("password")
                } catch {
                    return database.eventLoop.future(error: error)
                }
                return User(
                    name: "Alex",
                    username: "alchwi",
                    passwordHash: passwordHash
                )
                    .save(on: database)
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
