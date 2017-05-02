
import Foundation

class World {

    let entryRoom: Room // = GenericRoom(title: "The Foyer")

    private var users: [String: User] = [:]

    private var userRooms: [User: Room] = [:]

    init() {
        guard let entryRoom = RoomFactory.loadRooms(from: "map.json", withFirstRoom: "entry") else {
            fatalError("failed to load rooms")
        }

        self.entryRoom = entryRoom
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

    func move(user: User, to room: Room) {
        let existingRoom = userRooms[user]!
        existingRoom.onExit(world: self, to: room)
        userRooms[user] = room
        room.onEntry(world: self, from: existingRoom)
    }

    func users(in room: Room) -> [User] {
        var users = [User]()

        for user in userRooms.keys {

            guard room === userRooms[user]! else {
                continue
            }

            users.append(user)
        }

        return users
    }
}
