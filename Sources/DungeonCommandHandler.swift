
protocol DungeonCommandHandler: CustomStringConvertible {

    /// return false to disconnect this client
    func execute(args: String, with io: TerminalIO, in world: World) -> Bool

}

class LookHandler: DungeonCommandHandler {

    var description: String {
        return "shows information about the current room"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {

        let room = world.room(for: Context.get().user!)!

        guard io.print("You are in \(room.titleInRoom())\n") else {
            return false
        }

        guard showExits(for: room, with: io) else {
            return false
        }

        // TODO show other players here

        return true
    }

    private func showExits(for room: Room, with io: TerminalIO) -> Bool {
        guard room.exits.count > 0 else {
            return true
        }

        guard io.print("\nExits:\n") else {
            return false
        }

        for exit in room.exits.keys {

            let room = room.exits[exit]!
            guard io.print("\(exit) : \(room.titleAsExit(to: exit))\n") else {
                return false
            }

        }

        guard io.print("\n") else {
            return false
        }

        return true
    }

}

class QuitHandler: DungeonCommandHandler {

    var description: String {
        return "[message] - exit SwiftMud with optional message"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {
        let _ = io.print("Thanks for playing. Please come back soon!\n\n")
        log(tag: self, message: "User has quit with args: [\(args)]")
        return false
    }

}

class HelpHandler: DungeonCommandHandler {

    var description: String {
        return "shows this command"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {
        log(tag: self, message: "help")

        for commandName in DungeonHandler.commands.keys.sorted() {
            let command = DungeonHandler.commands[commandName]!

            // TODO have a help item on the command
            guard io.print("\(commandName) : \(command)\n") else {
                return false
            }
        }

        return true
    }

}

class GoHandler: DungeonCommandHandler {

    let direction: String?

    init() {
        direction = nil
    }

    init(direction: String) {
        self.direction = direction
    }

    var description: String {
        return "<direction> - head in specified direction"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {
        log(tag: self, message: "go \(direction ?? args)")

        guard let user = Context.get().user else {
            return false
        }

        guard let room = world.room(for: user) else {
            return false
        }

        guard let destination = room.exits[direction ?? args] else {
            guard io.print("You can't head \(direction ?? args).\n") else {
                return false
            }
            return true
        }

        guard io.print("You head \(direction ?? args).\n\n") else {
            return false
        }

        world.move(user: user, to: destination)
        return true
    }

}
