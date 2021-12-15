import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { request in
        "Hello World"
    }
    let controllers: [RouteCollection] = [
        CarsController(),
        UsersController()
    ]
    try controllers.forEach { controller in
        try app.register(collection: controller)
    }
}
