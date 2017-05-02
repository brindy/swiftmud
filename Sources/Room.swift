
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

