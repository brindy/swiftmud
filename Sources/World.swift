
struct User {
    
    var name: String
    var password: String
    
}


class World {
    
    var users: [String: User] = [:]
    
    func findUser(with name: String) -> User? {
        print("World", "find user \(name) in \(users)")
        return users[name]
    }
    
    func update(user: User) {
        print("World", "updating user \(user)")
        users[user.name] = user
    }
    
}

