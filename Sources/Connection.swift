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
            
            commandHandler = commandHandler.handle(connection: self)
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

        return message.trimmingCharacters(in: .whitespaces)
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
