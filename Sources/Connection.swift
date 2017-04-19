import Sockets
import Transport

protocol TerminalIO {

    func readLine() -> String?
    
    func write(string: String) -> Bool
    
}

class Connection: TerminalIO {

    var commandHandler: CommandHandler! = LoginHandler()

    let client: TCPInternetSocket
    let world: World
    
    init(client: TCPInternetSocket, world: World) {
        self.client = client
        self.world = world
    }
    
    func start() {
        log(tag: self, message: "client start: \(String(describing: client.address))")
        
        while(true) {
            guard commandHandler != nil else {
                log(tag: self, message: "no command handler")
                return
            }
            
            commandHandler = commandHandler.handle(io: self, world: world)
        }
        
    }
    
    func readLine() -> String? {
        
        guard let message = try? client.read(max: 2048).makeString() else {
            log(tag: self, message: "client closed, error reading stream: \(String(describing: client.address))")
            return nil
        }
        
        guard message != "" else {
            log(tag: self, message: "client closed, no data in steam: \(String(describing: client.address))")
            return nil
        }

        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func write(string: String) -> Bool {
        
        do {
            try client.write(string)
        } catch {
            return false
        }
        
        return true
        
    }

}


extension Connection: Hashable, Equatable {
    
    public var hashValue: Int {
        return String(describing: client).hashValue
    }
    
    public static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return String(describing: lhs.client) == String(describing: rhs.client)
    }
    
}
