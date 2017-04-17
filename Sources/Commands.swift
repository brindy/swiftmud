
protocol CommandHandler {
    
    func handle(message: String, forConnection: Connection) -> CommandHandler?
    
}

class LoginHandler: CommandHandler {
    
    func handle(message: String, forConnection connection: Connection) -> CommandHandler? {
        print("LoginHandler - handle IN")
        
        guard connection.write(string: "echo: \(message)") else {
            print("LoginHandler - failed to write echo OUT")
            return nil
        }
        
        print("LoginHandler - handle OUT")
        return self
    }
    
}
