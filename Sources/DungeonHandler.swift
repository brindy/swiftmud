
class DungeonHandler: CommandHandler {
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        log(tag: self, message: "handle IN")
        
        guard io.write(string: "Welcome to swiftmud. ") else {
            log(tag: self, message: "failed to write welcome message")
            return nil
        }
        
        while(true) {
            guard io.write(string: "> ") else {
                log(tag: self, message: "failed to write prompt")
                return nil
            }
            
            guard let line = io.readLine() else {
                log(tag: self, message: "failed to read line")
                return nil
            }

            if line == "quit" {
                break
            }

            guard io.write(string: "Sorry, I don't know how to '\(line)'\n") else {
                log(tag: self, message: "failed to echo line")
                return nil
            }

        }
        
        log(tag: self, message: "handle OUT")
        return nil
    }
    
}
