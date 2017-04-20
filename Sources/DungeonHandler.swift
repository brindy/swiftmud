
class DungeonHandler: CommandHandler {

    let commands = [
        "quit" : QuitHandler()
    ]

    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        log(tag: self, message: "handle IN, commands: \(commands)")
        
        guard io.print("Welcome to SwiftMud. \n") else {
            log(tag: self, message: "failed to write welcome message")
            return nil
        }

        // io.broadcast(to: world.entryRoom().users, "\(user.name) has materialised.")

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
            if let handler = commands[command] {
                let args = line.substring(from: line.index(line.startIndex, offsetBy: command.utf8.count)).trimmingCharacters(in: .whitespacesAndNewlines)
                log(tag: self, message: "args: \(args)")

                guard handler.execute(args: args, with: io, in: world) else {
                    log(tag: self, message: "handler has failed (or quit)")
                    return nil
                }
            }

            guard io.print("Sorry, I don't know how to '\(line)'\n") else {
                log(tag: self, message: "failed to echo line")
                return nil
            }

        }
        
        log(tag: self, message: "handle OUT")
        return self
    }
    
}

protocol DungeonCommandHandler: CustomStringConvertible {

    func execute(args: String, with io: TerminalIO, in world: World) -> Bool

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