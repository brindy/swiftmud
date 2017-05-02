
import Foundation

class World {

    private var users: [String: User] = [:]
    private var userRooms: [User: Room] = [:]

    let entryRoom: Room

    init() {
        guard let entryRoom = WorldBuilder(jsonFile: "map.json", entryRoomId: "entry").loadRooms() else {
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

    func remove(user: User) {
        userRooms[user] = nil
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

class WorldBuilder {

    let jsonFile: String
    let entryRoomId: String

    private var jsonDict: [String: Any]!
    private var roomsDict: [String: Any]!

    private var rooms: [String: Room] = [:]

    init(jsonFile: String, entryRoomId: String) {
        self.jsonFile = jsonFile
        self.entryRoomId = entryRoomId
    }

    func loadRooms() -> Room? {

        log(tag: self, message: "loading data from \(jsonFile)")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: jsonFile)) else {
            log(tag: self, message: "failed to read \(jsonFile)")
            return nil
        }

        log(tag: self, message: "deserialising \(String(bytes: data, encoding: .utf8)!)")
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            log(tag: self, message: "failed to deserialise json")
            return nil
        }

        guard let jsonDict = json as? [String: Any] else {
            log(tag: self, message: "failed to get json dictionary from json")
            return nil
        }
        self.jsonDict = jsonDict

        guard let roomsDict = jsonDict["rooms"] as? [String: Any] else {
            log(tag: self, message: "failed to get rooms dictionary from json dictionary")
            return nil
        }
        self.roomsDict = roomsDict

        for roomId in roomsDict.keys.sorted() {
            let _ = createRoom(roomId, "")
        }

        return rooms[entryRoomId]
    }

    func createRoom(_ id: String, _ indent: String) -> Room? {
        log(tag: self, message: "\(indent)createRoom with id '\(id)' - IN")

        guard rooms[id] == nil else {
            log(tag: self, message: "\(indent)room with id '\(id)' already exists - OUT")
            return rooms[id]
        }

        guard let roomDict = roomsDict[id] as? [String: Any] else {
            fatalError("Room dict with name '\(id)' does not exist!")
        }

        let title = roomDict["title"] as? String
        let room = Room(id: id, title: title)
        rooms[id] = room

        if let className = roomDict["class"] as? String {
            room.logic = loadRoomLogic(className)
        }

        guard let exits = roomDict["exits"] as? [String: Any] else {
            log(tag: self, message: "\(indent)room with id '\(id)' has no exits - OUT")
            return room
        }

        for exitName in exits.keys {
            log(tag: self, message: "\(indent)adding exit '\(exitName)' to \(room.id)")

            let exit = exits[exitName] as! [String: Any]

            guard let destination = exit["destination"] as? String else {
                log(tag: self, message: "\(indent)exit '\(exitName)' for \(room.id) has no 'room' property")
                continue
            }

            guard let destinationDescription = exit["description"] as? String else {
                log(tag: self, message: "\(indent)exit '\(exitName)' for \(room.id) has no 'description' property")
                continue
            }

            log(tag: self, message: "\(indent)\(room.id), \(exitName): \(destinationDescription)")
            room.exits[exitName] = createRoom(destination, indent + "    ")
            room.exitDescriptions[exitName] = destinationDescription
        }

        log(tag: self, message: "\(indent)\(room.id) created - OUT")
        return room
    }

    func loadRoomLogic(_ className: String) -> RoomLogic {

        let name = String(reflecting: self)
        let components = name.components(separatedBy: ".")

        var namespace = "SwiftMud"
        if components.count > 1 {
            namespace = components[0]
        }

        let cls = NSClassFromString("\(namespace).\(className)")! as! RoomLogic.Type
        let room = cls.init()

        return room
    }

}
