
struct User {
    
    var name: String
    var password: String
    
}


class World {
    
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

