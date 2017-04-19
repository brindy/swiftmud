
class NavigationHandler: CommandHandler {
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        print("NavigationHandler", "handle IN")
        
        guard io.write(string: "Welcome to swiftmud. ") else {
            print("NavigationHandler", "failed to write welcome message")
            return nil
        }
        
        while(true) {
            guard io.write(string: "> ") else {
                print("NavigationHandler", "failed to write prompt")
                return nil
            }
            
            guard let line = io.readLine() else {
                print("NavigationHandler", "failed to read line")
                return nil
            }
            
            guard io.write(string: "echo: \(line)") else {
                print("NavigationHandler", "failed to echo line")
                return nil
            }
            
        }
        
        print("NavigationHandler", "handle OUT")
        return self
    }
    
}
