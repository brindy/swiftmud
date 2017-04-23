
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


class World {

    let entryRoom = Room()

    var users: [String: User] = [:]
    
    func findUser(with name: String) -> User? {
        log(tag: "World", message: "find user \(name) in \(users)")
        return users[name]
    }
    
    func update(user: User) {
        log(tag: "World", message: "updating user \(user)")
        users[user.name] = user
    }

}

class Room {

    var users:Set<User> = []

}
