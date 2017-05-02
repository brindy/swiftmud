
import Foundation

class Room {

    var logic: RoomLogic?

    var id: String
    var roomTitle: String?
    var exits = [String: Room]()
    var exitDescriptions = [String: String]()

    init(id: String, title: String?) {
        self.id = id
        self.roomTitle = title
    }

    func title() -> String {
        return logic?.title() ?? id // roomTitle ?? id
    }

    func title(seenFrom room: Room) -> String {
        return logic?.title(seenFrom: room) ?? title()
    }

    func onEntry(world: World, from: Room) {
        guard let user = Context.get().user else {
            return
        }

        var incomingDirection = ""
        if let direction = self.direction(of: from) {
            incomingDirection = " from the \(direction)"
        }
        // connection.broadcast(to: Array(users), "")
        print("👤 \(user.name) has arrived\(incomingDirection)", exceptTo: user)

        logic?.onEntry(world: world, from: from)
    }

    func onExit(world: World, to: Room) {
        guard let user = Context.get().user else {
            return
        }

        var outgoingDirection = " has left"
        if let direction = self.direction(of: to) {
            outgoingDirection = " heads to the \(direction)"
        }
        print("👤 \(user.name)\(outgoingDirection)", exceptTo: user)

        logic?.onExit(world: world, to: to)
    }

    func print(_ message: String, exceptTo hiddenTo: User? = nil) {

        let world = Context.get().world
        let server = Context.get().server

        var users = Set(world!.users(in: self))
        if let hiddenTo = hiddenTo {
            users.remove(hiddenTo)
        }

        log(tag: self, message: "broadcasting to users \(String(describing: users))")

        for connection in server!.connections {
            log(tag: self, message: "broadcasting to \(connection)")

            guard let connectedUser = connection.user else {
                log(tag: self, message: "\(connection) has no user")
                continue
            }

            guard users.contains(where: { $0.name == connectedUser.name}) else {
                log(tag: self, message: "\(connectedUser) is not in broadcast list")
                continue
            }

            let _ = connection.print("\(message)\n> ")
        }

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

protocol RoomLogic {

    init()

    func title() -> String?
    func title(seenFrom room: Room) -> String?
    func onEntry(world: World, from: Room)
    func onExit(world: World, to: Room)

}

extension RoomLogic {

    func title() -> String? {
        return nil
    }

    func title(seenFrom room: Room) -> String? {
        return nil
    }

    func onEntry(world: World, from: Room) {
    }

    func onExit(world: World, to: Room) {
    }

}

class DeathRoom: RoomLogic {

    required init() {
    }

    func onEntry(world: World, from: Room) {

        if let connection = Context.get().connection {
            let _  = connection.format().red().print("All that glitters is not gold!.\n\n")
            let _  = connection.format().red().bold().print("You are dead.\n\n")
            connection.disconnect()
        }

    }

}
