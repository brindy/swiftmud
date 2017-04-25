
import Foundation

class World {

    let entryRoom = Room(title: "The Foyer")

    private var users: [String: User] = [:]

    private var userRooms: [User: Room] = [:]

    init() {
        let deathRoom = Room(title: "Death Room")
        entryRoom.exits["north"] = deathRoom
    }

    func add(user: User) {
        users[user.name] = user
        userRooms[user] = entryRoom
    }

    func findUser(with name: String) -> User? {
        log(tag: "World", message: "find user \(name) in \(users)")
        return users[name]
    }
    
    func update(user: User) {
        log(tag: "World", message: "updating user \(user)")
        users[user.name] = user
    }

    func room(for user: User) -> Room? {
        return userRooms[user]
    }

    func users(in room: Room) -> [User] {
        var users = [User]()

        for user in userRooms.keys {

            guard room == userRooms[user]! else {
                continue
            }

            users.append(user)
        }

        return users
    }
}
