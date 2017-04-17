import Sockets
import Transport

class Connection {

    lazy var commandHandler: CommandHandler! = LoginHandler()

    let client: TCPInternetSocket
    
    init(client: TCPInternetSocket) {
        self.client = client
    }
    
    func start() {
        print("client start: \(String(describing: client.address))")
        
        while(true) {
            guard commandHandler != nil else {
                print("no command handler")
                return
            }
            
            guard let message = readLine() else {
                print("failed to read line")
                return
            }
            
            commandHandler = commandHandler.handle(message: message, forConnection: self)
        }
        
    }
    
    func readLine() -> String? {
        
        guard let message = try? client.read(max: 2048).makeString() else {
            print("client closed, error reading stream: \(String(describing: client.address))")
            return nil
        }
        
        guard message != "" else {
            print("client closed, no data in steam: \(String(describing: client.address))")
            return nil
        }

        return message
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
