
// TODO connection should have 'current user'
// TODO need to pass around the 'world' context
class LoginHandler: CommandHandler {
    
    func handle(connection: Connection) -> CommandHandler? {
        print("LoginHandler", "handle IN")
        
        guard let name = readName(from: connection) else {
            print("LoginHandler", "failed to read name OUT")
            return nil
        }

        guard connection.write(string: "Hello, \(name)") else {
            print("LoginHandler", "failed to send hello")
            return nil
        }
        
        guard let message = connection.readLine() else {
            print("LoginHandler", "failed to read message OUT")
            return nil
        }
        
        guard connection.write(string: "Hello, \(message)") else {
            print("LoginHandler", "failed to write echo OUT")
            return nil
        }
        
        // TODO if new, create password
        
        // TODO if not new, enter password
        
        print("LoginHandler", "handle OUT")
        return self
    }
    
    func readName(from connection: Connection) -> String? {
        
        guard let line = connection.readLine() else {
            print("LoginHandler", "failed to read line")
            return nil
        }
        
        return line
    }
    
}
