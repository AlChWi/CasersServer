import Fluent
import Vapor

final class SealedCargo: Model, Content {
    static let schema = "cargo"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "number")
    var number: String
    
    @OptionalParent(key: "carID")
    var car: Car?
    
    @OptionalParent(key: "trailerID")
    var trailer: CarTrailer?
    
    init() { }
    
    init(
        id: UUID? = nil,
        number: String,
        carID: Car.IDValue?,
        trailerID: CarTrailer.IDValue?
    ) {
        self.id = id
        self.number = number
        self.$car.id = carID
        self.$trailer.id = trailerID
    }
}
