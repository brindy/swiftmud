import Foundation

class ConnectionProperties {

    static func instance() -> ConnectionProperties {
        var properties = Thread.current.threadDictionary["properties"] as? ConnectionProperties
        if properties == nil {
            properties = ConnectionProperties()
            Thread.current.threadDictionary["properties"] = properties
        }
        return properties!
    }

    static func kill() {
        Thread.current.threadDictionary["properties"] = nil
    }

    var connection: Connection?
    var user: User?

    deinit {
        log(tag: self, message: "deinit")
    }

}
