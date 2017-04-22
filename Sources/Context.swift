import Foundation

class Context {

    static func get() -> Context {
        var properties = Thread.current.threadDictionary["properties"] as? Context
        if properties == nil {
            properties = Context()
            Thread.current.threadDictionary["properties"] = properties
        }
        return properties!
    }

    static func dispose() {
        Thread.current.threadDictionary["properties"] = nil
    }

    var connection: Connection?
    var user: User?

    deinit {
        log(tag: self, message: "deinit")
    }

}
