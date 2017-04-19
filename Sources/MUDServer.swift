
import Dispatch
import Sockets
import Transport

class MUDServer {

    let world = World()
    
    var connections: Set<Connection> = []
    
	let port:Int

	init(port: Int) {
		self.port = port
    }

	func start() {
		print("starting on \(port)")
        
        guard let serverStream = try? TCPInternetSocket(scheme: "mud", hostname: "0.0.0.0", port: UInt16(port)) else {

            print("failed to start server")
            
            return
        }
        
        try? serverStream.bind()
        try? serverStream.listen(max: 4096)
        
        while let client = try? serverStream.accept() {
            
            print("client accepted: \(String(describing: client.address))")
            
            background {
                print("new background thread for \(String(describing: client.address))")
                let connection = Connection(client: client, world: self.world)
                self.connections.insert(connection)
                connection.start()
                self.connections.remove(connection)
                print("background thread finished for \(String(describing: client.address))")
            }
            
        }
    }
    
}
