
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

        guard let serverSocket = startServer() else {
            return
        }

        acceptConnections(serverSocket)

    }

    private func acceptConnections(_ serverSocket: TCPInternetSocket) {
        while let client = try? serverSocket.accept() {

            log(tag: self, message: "client accepted: \(String(describing: client.address))")

            background {
                log(tag: self, message: "new background thread for \(String(describing: client.address))")

                self.handleConnection(client)

                log(tag: self, message: "background thread finished for \(String(describing: client.address))")
                try? client.close()
            }

        }
    }

    private func startServer() -> TCPInternetSocket? {
        log(tag: self, message: "starting on \(port)")

        guard let serverSocket = try? TCPInternetSocket(scheme: "mud", hostname: "0.0.0.0", port: UInt16(port)) else {
            log(tag: self, message: "failed to start server")
            return nil
        }

        try? serverSocket.bind()
        log(tag: self, message: "server is bound")
        try? serverSocket.listen(max: 4096)
        log(tag: self, message: "server is ready to accept connections")
        return serverSocket
    }

    private func handleConnection(_ client: TCPInternetSocket) {
        let connection = Connection(server: self, client: client, world: self.world)

        Context.get().connection = connection

        self.connections.insert(connection)
        log(tag: self, message: "we now have \(self.connections.count) connections")

        connection.start()

        self.connections.remove(connection)

        if let user = Context.get().user {
            // TODO remove user from world (not delete)
            // TODO broadcast disconnection
        }

        Context.dispose()
    }

}
