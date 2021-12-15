import Fluent
import Vapor

final class Car: Model, Content {
    static let schema = "cars"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "sign")
    var sign: String
    
    @Timestamp(key: "registered_at", on: .create)
    var registeredAt: Date?
    
    @Parent(key: "driverID")
    var driver: Driver
    
    @OptionalChild(for: \.$car)
    var trailer: CarTrailer?
    
    @Children(for: \.$car)
    var sealedCargo: [SealedCargo]

    init() { }

    init(
        id: UUID? = nil,
        sign: String,
        driverID: Driver.IDValue
    ) {
        self.id = id
        self.sign = sign
        self.$driver.id = driverID
    }
}
