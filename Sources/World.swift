
import Foundation

class World {

    let entryRoom: Room // = GenericRoom(title: "The Foyer")

    private var users: [String: User] = [:]

    private var userRooms: [User: Room] = [:]

    init() {
        guard let entryRoom = WorldBuilder.loadRooms(from: "map.json", withFirstRoom: "entry") else {
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

class WorldBuilder {

    static func loadRooms(from jsonFile: String, withFirstRoom firstRoomName: String) -> Room? {

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

        guard let roomsDict = json as? [String: Any] else {
            log(tag: self, message: "failed to get rooms dictionary from json")
            return nil
        }

        var rooms: [String: Room] = [:]

        for roomId in roomsDict.keys.sorted() {
            let _ = createRoom(roomId, roomsDict, &rooms, "")
        }

        return rooms[firstRoomName]
    }

    static func createRoom(_ id: String, _ json: [String: Any], _ rooms: inout [String: Room], _ ident: String) -> Room? {
        log(tag: self, message: "\(ident)createRoom with id '\(id)' - IN")

        guard rooms[id] == nil else {
            log(tag: self, message: "\(ident)room with id '\(id)' already exists - OUT")
            return rooms[id]
        }

        guard let roomDict = json[id] as? [String: Any] else {
            fatalError("Room dict with name '\(id)' does not exist!")
        }

        if let className = roomDict["class"] as? String {
            log(tag: self, message: "\(ident)loading room with name class name \(className)")
            rooms[id] = loadRoom(className)
        } else if let title = roomDict["title"] as? String {
            log(tag: self, message: "\(ident)creating generic room with title \(title)")
            rooms[id] = GenericRoom(title: title)
        } else {
            log(tag: self, message: "\(ident)invalid room!")
            return nil
        }

        let room = rooms[id]!

        guard let exits = roomDict["exits"] as? [String: Any] else {
            return nil
        }

        for exitName in exits.keys {
            log(tag: self, message: "\(ident)adding exit '\(exitName)' to \(room.titleInRoom())")

            let exit = exits[exitName] as! [String: Any]

            guard let destination = exit["destination"] as? String else {
                log(tag: self, message: "\(ident)exit '\(exitName)' for \(room.titleInRoom()) has no 'room' property")
                continue
            }

            guard let destinationDescription = exit["description"] as? String else {
                log(tag: self, message: "\(ident)exit '\(exitName)' for \(room.titleInRoom()) has no 'description' property")
                continue
            }

            log(tag: self, message: "\(ident)\(room.titleInRoom()), \(exitName): \(destinationDescription)")
            room.exits[exitName] = createRoom(destination, json, &rooms, ident + "    ")
            room.exitDescriptions[exitName] = destinationDescription
        }

        log(tag: self, message: "\(ident)\(room.titleInRoom()) created - OUT")
        return room
    }

    static func loadRoom(_ className: String) -> Room {

        let name = String(reflecting: self)
        let components = name.components(separatedBy: ".")

        var namespace = "SwiftMud"
        if components.count > 1 {
            namespace = components[0]
        }

        let cls = NSClassFromString("\(namespace).\(className)")! as! Room.Type
        let room = cls.init()

        return room
    }

}