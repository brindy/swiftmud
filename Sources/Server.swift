
import Foundation
import Dispatch
import Sockets
import Transport

class Server {

    let world = World()
    
    var connections: Set<Connection> = []
    
	let port:Int

	init(port: Int) {
		self.port = port
    }

	func start() {
        log(tag: self, message: "starting on \(port)")
        
        guard let serverSocket = try? TCPInternetSocket(scheme: "mud", hostname: "0.0.0.0", port: UInt16(port)) else {
            log(tag: self, message: "failed to start server")
            return
        }
        
        try? serverSocket.bind()
        log(tag: self, message: "server is bound")
        try? serverSocket.listen(max: 4096)
        log(tag: self, message: "server is ready to accept connections")

        while let client = try? serverSocket.accept() {

            log(tag: self, message: "client accepted: \(String(describing: client.address))")
            
            background {
                log(tag: self, message: "new background thread for \(String(describing: client.address))")

                let connection = Connection(client: client, world: self.world)

                Context.get().connection = connection

                self.connections.insert(connection)
                connection.start()
                self.connections.remove(connection)

                Context.dispose()

                log(tag: self, message: "background thread finished for \(String(describing: client.address))")
                try? client.close()
            }
            
        }

    }
    
}
