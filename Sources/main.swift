
import Foundation

var serverPort = 20176

if CommandLine.arguments.count > 1, let port = Int(CommandLine.arguments[1] as String) {
    serverPort = port
}

Server(port: serverPort).start()

// MARK: Global functions

func log(tag: Any, message: String) {
    var tag = tag is String ? tag : Mirror(reflecting: tag).subjectType
    if let connection = Context.get().connection {
        tag = "\(connection)] [\(tag)]"
    }
    print("[\(Date())] [\(serverPort)] [\(tag)]", message)
}

extension String {

    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

}