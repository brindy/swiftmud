
protocol CommandHandler {
    
    func handle(io: TerminalIO, world: World) -> CommandHandler?
    
}

