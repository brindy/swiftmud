
import Foundation

protocol Room: class {

    var exits: [String: Room] {
        get
    }

    // Show the title as seen in the given direction of whatever room is currently being occupied
    func titleAsExit(to direction: String) -> String

    // The title of the room when in it
    func titleInRoom() -> String

    /// Called when the user enters the room
    func onEntry(world: World, from: Room);

    /// Called when the user leaves the room
    func onExit(world: World, to: Room);

}

class BaseRoom: Room {

    var exits = [String: Room]()

    func titleAsExit(to direction: String) -> String {
        fatalError("override required")
    }

    func titleInRoom() -> String {
        fatalError("override required")
    }

    func onEntry(world: World, from: Room) {
    }

    func onExit(world: World, to: Room) {
    }

}

class GenericRoom: BaseRoom {

    let title: String

    init(title: String) {
        self.title = title
    }

    override func titleAsExit(to direction: String) -> String {
        return title
    }

    override func titleInRoom() -> String {
        return title
    }

    override func onEntry(world: World, from: Room) {

        guard let user = Context.get().user else {
            return
        }

        var users = Set<User>(world.users(in: self))
        users.remove(user)

        guard let connection = Context.get().connection else {
            return
        }

        // TODO handle direction?
        connection.broadcast(to: Array(users), "\(user.name) has arrived")
    }

}

class DeathRoom: BaseRoom {

    override func titleAsExit(to direction: String) -> String {
        return "the glittering of what appears to be gold"
    }

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
