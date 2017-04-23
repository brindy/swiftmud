import Sockets
import Transport

protocol TerminalIO {

    func readLine() -> String?
    
    func print(_ string: String) -> Bool

    func broadcast(to: [User], _ string: String)
}

class Connection: TerminalIO, Hashable, Equatable {

    var user: User? {
        get {
            return context.user
        }
    }

    var description: String {
        get {
            return String(describing: client.address)
        }
    }

    private var commandHandler: CommandHandler! = LoginHandler()
    private weak var context:Context! = Context.get()
    private weak var server: Server?
    private let client: TCPInternetSocket
    private let world: World

    init(server: Server, client: TCPInternetSocket, world: World) {
        self.server = server
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
    
    func print(_ string: String) -> Bool {
        
        do {
            try client.write(string)
        } catch {
            return false
        }
        
        return true
    }

    func broadcast(to users: [User], _ string: String) {
        log(tag: self, message: "broadcasting to users \(users)")

        for connection in server!.connections {
            log(tag: self, message: "broadcasting to \(connection)")

            guard let connectedUser = connection.user else {
                log(tag: self, message: "\(connection) has no user")
                continue
            }

            guard users.contains(where: { $0.name == connectedUser.name}) else {
                log(tag: self, message: "\(connectedUser) is not in broadcast list")
                continue
            }

            let _ = connection.print("\(string)\n> ")
        }

    }

    public var hashValue: Int {
        return String(describing: client.address).hashValue
    }

    public static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return String(describing: lhs.client.address) == String(describing: rhs.client.address)
    }

    deinit {
        // TODO remove this user from any rooms they're in
        log(tag: self, message: "deinit")
    }

}
