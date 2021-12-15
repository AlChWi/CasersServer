import Fluent
import Vapor

final class CarTrailer: Model, Content {
    static let schema = "car_trailers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "sign")
    var sign: String
    
    @Parent(key: "carID")
    var car: Car
    
    @Children(for: \.$trailer)
    var sealedCargo: [SealedCargo]
    
    init() { }
    
    init(
        id: UUID? = nil,
        sign: String,
        carID: Car.IDValue
    ) {
        self.id = id
        self.sign = sign
        self.$car.id = carID
    }
}

