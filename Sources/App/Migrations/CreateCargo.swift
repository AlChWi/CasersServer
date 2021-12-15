import Fluent

struct CreateCargo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SealedCargo.schema)
            .id()
            .field("number", .string, .required)
            .field(
                "carID",
                .uuid,
                .references(
                    Car.schema,
                    .id,
                    onDelete: .cascade,
                    onUpdate: .cascade
                )
            )
            .field(
                "trailerID",
                .uuid,
                .references(
                    CarTrailer.schema,
                    .id,
                    onDelete: .cascade,
                    onUpdate: .cascade
                )
            )
            .unique(on: "number")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SealedCargo.schema).delete()
    }
}
