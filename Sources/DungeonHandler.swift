
typealias DungeonCommandHandlerFactory = () -> DungeonCommand

class DungeonHandler: CommandHandler {

    static let commands: [String: DungeonCommandHandlerFactory] = [

        "quit"  : { QuitCommand() },
        "help"  : { HelpCommand() },
        "look"  : { LookCommand() },
        "go"    : { GoCommand() },

    ]

    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        log(tag: self, message: "handle IN, commands: \(DungeonHandler.commands)")

        let user = Context.get().user!

        guard beginSession(io, world, user) else {
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

            var handler = DungeonHandler.commands[command]

            if handler == nil { // unknown command, check to see if the current room has a matching direction
                handler = roomExitHandler(command, user, world)
            }

            // TODO (future) objects in the room might have handlers

            if handler == nil { // still no command, report to the user and wait for further input

                if line == "" {
                    continue
                }

                guard io.print("Sorry, I don't know how to '\(line)'\n") else {
                    log(tag: self, message: "failed to echo line")
                    return nil
                }

                continue
            }

            guard processCommand(line, command, world, io, handler!) else {
                return nil
            }
        }
        
    }

    private func beginSession(_ io: TerminalIO, _ world: World, _ user: User) -> Bool {
        guard io.print("Welcome to SwiftMud. \n") else {
            log(tag: self, message: "failed to write welcome message")
            return false
        }

        world.entryRoom.print("👤\(user.name) has materialised.")
        world.add(user: user)

        guard LookCommand().execute(args: "", with: io, in: world) else {
            log(tag: self, message: "initial LookHandler failed")
            return false
        }

        return true
    }

    private func processCommand(_ line: String, _ command: String, _ world: World, _ io: TerminalIO, _ handler: DungeonCommandHandlerFactory) -> Bool {
        let args = line.substring(from: line.index(line.startIndex, offsetBy: command.utf8.count)).trimmingCharacters(in: .whitespacesAndNewlines)
        log(tag: self, message: "args: \(args)")

        guard handler().execute(args: args, with: io, in: world) else {
            log(tag: self, message: "handler has failed")
            return false
        }

        return true
    }

    private func roomExitHandler(_ command: String, _ user: User, _ world: World) -> DungeonCommandHandlerFactory? {
        if world.room(for: user)?.exits[command] != nil {
            return { GoCommand(direction: command) }
        }
        return nil
    }
    
}

