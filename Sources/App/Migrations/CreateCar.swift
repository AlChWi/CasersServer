import Fluent

struct CreateCar: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Car.schema)
            .id()
            .field("sign", .string, .required)
            .field("registered_at", .datetime)
            .field(
                "driverID",
                .uuid,
                .required,
                .references(
                    Driver.schema,
                    .id,
                    onDelete: .cascade,
                    onUpdate: .cascade
                )
            )
            .unique(on: "sign")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Car.schema).delete()
    }
}
