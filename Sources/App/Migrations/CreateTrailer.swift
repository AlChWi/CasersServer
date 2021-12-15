import Fluent

struct CreateCarTrailer: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(CarTrailer.schema)
            .id()
            .field("sign", .string, .required)
            .field(
                "carID",
                .uuid,
                .required,
                .references(
                    Car.schema,
                    .id,
                    onDelete: .cascade,
                    onUpdate: .cascade
                )
            )
            .unique(on: "sign")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(CarTrailer.schema).delete()
    }
}
