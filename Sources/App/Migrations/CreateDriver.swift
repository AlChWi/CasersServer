import Fluent

struct CreateDriver: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Driver.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Driver.schema).delete()
    }
}
