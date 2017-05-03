
protocol DungeonCommand: CustomStringConvertible {

    /// return false to disconnect this client
    func execute(args: String, with io: TerminalIO, in world: World) -> Bool

}

extension DungeonCommand {

    func currentRoom() -> Room? {
        guard let world = Context.get().world else {
            log(tag: self, message: "no world")
            return nil
        }

        guard let user = Context.get().user else {
            log(tag: self, message: "no user")
            return nil
        }

        guard let room = world.room(for: user) else {
            log(tag: self, message: "user \(user.name) is not a room")
            return nil
        }

        return room
    }

}

class LookCommand: DungeonCommand {

    var description: String {
        return "shows information about the current room"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {

        guard let room = currentRoom() else {
            return false
        }

        guard io.print("\(room.title())\n") else {
            return false
        }

        guard showExits(for: room, with: io) else {
            return false
        }

        guard showUsers(for: room, with: io, in: world) else {
            return false
        }

        return true
    }

    private func showUsers(for room: Room, with io: TerminalIO, in world: World) -> Bool {
        guard let user = Context.get().user else {
            log(tag: self, message: "no user")
            return false
        }

        var users = Set(world.users(in: room))
        users.remove(user)

        guard users.count > 0 else {
            return true
        }

        for user in users {
            guard io.print("👤 \(user.name) is here.\n") else {
                return false
            }
        }

        guard io.print("\n") else {
            return false
        }

        return true
    }

    private func showExits(for room: Room, with io: TerminalIO) -> Bool {
        guard room.exits.count > 0 else {
            return true
        }

        guard io.print("\nExits:\n") else {
            return false
        }

        for exit in room.exits {
            guard io.print("\(exit.key) : \(exit.value.title(seenFrom: room))\n") else {
                return false
            }
        }

        guard io.print("\n") else {
            return false
        }

        return true
    }

}

class QuitCommand: DungeonCommand {

    var description: String {
        return "[message] - exit SwiftMud with optional message"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {
        let _ = io.print("Thanks for playing. Please come back soon!\n\n")
        log(tag: self, message: "User has quit with args: [\(args)]")
        return false
    }

}

class HelpCommand: DungeonCommand {

    var description: String {
        return "shows this command"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {
        log(tag: self, message: "help")

        for commandName in DungeonHandler.commands.keys.sorted() {
            let command = DungeonHandler.commands[commandName]!

            guard io.print("\(commandName) : \(command().description)\n") else {
                return false
            }
        }

        return true
    }

}

class SpeakCommand: DungeonCommand {

    var description: String {
        return "say something in your current room"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {
        log(tag: self, message: "speak")

        guard let room = currentRoom() else {
            return false
        }

        guard let user = Context.get().user else {
            return false
        }

        let speakType = args.trim().hasSuffix("?") ? "ask" : "say"
        room.print("👤 \(user.name) 🗣 \(speakType)s '\(args)'", exceptTo: user)

        guard io.print("You \(speakType), '\(args)'\n") else {
            return false
        }

        return true
    }

}

class GoCommand: DungeonCommand {

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

        guard io.print("You head towards \(direction ?? args).\n\n") else {
            return false
        }

        world.move(user: user, to: destination)
        return LookCommand().execute(args: "", with: io, in: world)
    }

}
