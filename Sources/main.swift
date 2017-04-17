
var port = 20176

if CommandLine.arguments.count > 1, let portArg = Int(CommandLine.arguments[1] as String) {
    port = portArg
}

MUDServer(port: port).start()
