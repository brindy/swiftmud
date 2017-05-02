import Sockets
import Transport

protocol TerminalIO {

    func readLine() -> String?
    
    func print(_ string: String) -> Bool

}

extension TerminalIO {

    func format() -> FormattedIO {
        return FormattedIO(wrap: self)
    }

}

class FormattedIO: TerminalIO {

    let io: TerminalIO

    var formats = [String]()

    init(wrap io: TerminalIO) {
        self.io = io
    }

    // MARK: FormattedIO

    func red() -> FormattedIO {
        formats.append("31")
        return self
    }

    func bold() -> FormattedIO {
        formats.append("1")
        return self
    }

    // MARK: Terminal IO

    func readLine() -> String? {
        return io.readLine()
    }

    func print(_ string: String) -> Bool {
        let format = formats.joined(separator: ";")
        return io.print("\u{1b}[\(format)m\(string)\u{1b}[0m")
    }

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

    func disconnect() {
        try? client.close()
    }

    public var hashValue: Int {
        return String(describing: client.address).hashValue
    }

    public static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return String(describing: lhs.client.address) == String(describing: rhs.client.address)
    }

    deinit {
        log(tag: self, message: "deinit")
        if let user = Context.get().user {
            world.remove(user: user)
        }
    }

}
