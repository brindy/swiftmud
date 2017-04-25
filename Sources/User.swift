
struct User {

    var name: String
    var password: String

}

extension User: Hashable, Equatable {

    public var hashValue: Int {
        return name.hashValue
    }

    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }

}
