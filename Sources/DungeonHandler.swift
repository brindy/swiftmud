
typealias DungeonCommandHandlerFactory = () -> DungeonCommand

class DungeonHandler: CommandHandler {

    struct Command {

        var keywords: [String]
        var factory: DungeonCommandHandlerFactory

        func matches(keyword: String) -> Bool {
            return Set(keywords).contains(keyword)
        }

    }

    static let commands: [Command] = [

        Command(keywords: ["quit"], factory: { QuitCommand() }),
        Command(keywords: ["help"], factory: { HelpCommand() }),
        Command(keywords: ["look"], factory: { LookCommand() }),
        Command(keywords: ["go"], factory: { GoCommand() }),
        Command(keywords: ["say", "'"], factory: { SpeakCommand() }),

    ]

    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        log(tag: self, message: "handle IN, commands: \(DungeonHandler.commands)")

        let user = Context.get().user!

        guard beginSession(io, world, user) else {
            return nil
        }

        while(true) {

            guard let line = prompt(io) else {
                return nil
            }

            let keyword = line.components(separatedBy: " ")[0]
            log(tag: self, message: "keyword: \(keyword)")

            var factory = keywordCommandFactory(keyword)

            if factory == nil { // unknown command, check to see if the current room has a matching direction
                factory = roomExitCommandFactory(keyword, user, world)
            }

            // TODO (future) objects in the room might have handlers

            guard let foundFactory = factory else {
                guard unknownCommand(line, io) else {
                    return nil
                }
                continue
            }

            guard processKeyword(line, keyword, world, io, foundFactory) else {
                return nil
            }
        }
        
    }

    private func prompt(_ io: TerminalIO) -> String? {
        guard io.print("> ") else {
            log(tag: self, message: "failed to write prompt")
            return nil
        }

        guard let line = io.readLine() else {
            log(tag: self, message: "failed to read line")
            return nil
        }

        return line
    }

    private func unknownCommand(_ line: String, _ io: TerminalIO) -> Bool {
        guard line != "" else {
            return true
        }

        guard io.print("Sorry, I don't know how to '\(line)'\n") else {
            log(tag: self, message: "failed to echo line")
            return false
        }

        return true
    }

    private func keywordCommandFactory(_ keyword: String) -> DungeonCommandHandlerFactory? {
        for command in DungeonHandler.commands {
            if command.matches(keyword: keyword) {
                return command.factory
            }
        }
        return nil
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

    private func processKeyword(_ line: String, _ keyword: String, _ world: World, _ io: TerminalIO, _ factory: DungeonCommandHandlerFactory) -> Bool {
        let args = line.substring(from: line.index(line.startIndex, offsetBy: keyword.utf8.count)).trimmingCharacters(in: .whitespacesAndNewlines)
        log(tag: self, message: "args: \(args)")

        guard factory().execute(args: args, with: io, in: world) else {
            log(tag: self, message: "handler has failed")
            return false
        }

        return true
    }

    private func roomExitCommandFactory(_ command: String, _ user: User, _ world: World) -> DungeonCommandHandlerFactory? {
        if world.room(for: user)?.exits[command] != nil {
            return { GoCommand(direction: command) }
        }
        return nil
    }
    
}

