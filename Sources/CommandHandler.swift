
protocol CommandHandler {
    
    func handle(connection: Connection) -> CommandHandler?
    
}

