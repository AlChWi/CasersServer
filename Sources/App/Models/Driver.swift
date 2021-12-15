import Fluent
import Vapor

final class Driver: Model, Content {
    static let schema = "drivers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$driver)
    var cars: [Car]
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
