
import Foundation

class Room {

    required init() {
    }

    var exits = [String: Room]()
    var exitDescriptions = [String: String]()

    func titleAsExit(to direction: String) -> String {
        return exitDescriptions[direction]!
    }

    func titleInRoom() -> String {
        fatalError("override required")
    }

    func onEntry(world: World, from: Room) {
        guard let user = Context.get().user else {
            return
        }

        var users = Set<User>(world.users(in: self))
        users.remove(user)

        guard let connection = Context.get().connection else {
            return
        }

        // TODO handle direction?
        connection.broadcast(to: Array(users), "👤 \(user.name) has arrived")
    }

    func onExit(world: World, to: Room) {
        guard let user = Context.get().user else {
            return
        }

        var users = Set<User>(world.users(in: self))
        users.remove(user)

        guard let connection = Context.get().connection else {
            return
        }

        let theDirection = direction(of: to) ?? "somewhere else"
        connection.broadcast(to: Array(users), "👤 \(user.name) heads \(theDirection)")
    }

    private func direction(of room: Room) -> String? {
        for exit in exits {
            if exit.value === room {
                return exit.key
            }
        }
        return nil
    }

}


class GenericRoom: Room {

    let title: String

    required init() {
        title = "A generic room"
    }

    init(title: String) {
        self.title = title
    }

    override func titleInRoom() -> String {
        return title
    }

}


class DeathRoom: Room {

    override func titleInRoom() -> String {
        return "All that glitters, is not gold"
    }

    override func onEntry(world: World, from: Room) {

        if let connection = Context.get().connection {
            let _  = connection.print("You are dead.\n\n")
            connection.disconnect()
        }

    }

}

class RoomFactory {

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

            guard let destinationRoom = exit["room"] as? String else {
                log(tag: self, message: "\(ident)exit '\(exitName)' for \(room.titleInRoom()) has no 'room' property")
                continue
            }

            guard let destinationDescription = exit["description"] as? String else {
                log(tag: self, message: "\(ident)exit '\(exitName)' for \(room.titleInRoom()) has no 'description' property")
                continue
            }

            log(tag: self, message: "\(ident)\(room.titleInRoom()), \(exitName): \(destinationDescription)")
            room.exits[exitName] = createRoom(destinationRoom, json, &rooms, ident + "    ")
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