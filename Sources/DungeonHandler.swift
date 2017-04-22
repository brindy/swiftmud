
class DungeonHandler: CommandHandler {

    // TODO synonyms

    static let commands: [String: DungeonCommandHandler] = [
        "quit" : QuitHandler(),
        "help" : HelpHandler(),
        "look" : LookHandler(),
    ]

    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        log(tag: self, message: "handle IN, commands: \(DungeonHandler.commands)")
        
        guard io.print("Welcome to SwiftMud. \n") else {
            log(tag: self, message: "failed to write welcome message")
            return nil
        }

        // TODO broadcast to the room
        // io.broadcast(to: world.entryRoom().users, "\(user.name) has materialised.")
        // worldEntryRoom().add(user: user)

        guard LookHandler().execute(args: "", with: io, in: world) else {
            log(tag: self, message: "initial LookHandler failed")
            return nil
        }

        while(true) {

            guard io.print("> ") else {
                log(tag: self, message: "failed to write prompt")
                return nil
            }
            
            guard let line = io.readLine() else {
                log(tag: self, message: "failed to read line")
                return nil
            }

            let command = line.components(separatedBy: " ")[0]
            log(tag: self, message: "command: \(command)")
            guard let handler = DungeonHandler.commands[command] else {

                if line == "" {
                    continue
                }

                guard io.print("Sorry, I don't know how to '\(line)'\n") else {
                    log(tag: self, message: "failed to echo line")
                    return nil
                }

                continue
            }

            let args = line.substring(from: line.index(line.startIndex, offsetBy: command.utf8.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            log(tag: self, message: "args: \(args)")

            guard handler.execute(args: args, with: io, in: world) else {
                log(tag: self, message: "handler has failed \(handler)")
                return nil
            }
        }
        
//        log(tag: self, message: "handle OUT")
//        return self
    }
    
}

protocol DungeonCommandHandler: CustomStringConvertible {

    /// return false to disconnect this client
    func execute(args: String, with io: TerminalIO, in world: World) -> Bool

}

class LookHandler: DungeonCommandHandler {

    var description: String {
        return "shows information about the current room"
    }

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool {

        // TODO what room is the current user in?
        // let room = world.room(for: user)

        guard io.print("You are in a room.\n") else {
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
            guard io.print("\(commandName) : \(command)\n") else {
                return false
            }
        }

        return true
    }

}