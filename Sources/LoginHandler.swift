
class LoginHandler: CommandHandler {
    
    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        log(tag: self, message: "handle IN")
        
        guard let name = readName(from: io) else {
            log(tag: self, message: "failed to read name OUT")
            return nil
        }

        guard io.write(string: "Hello, \(name).  ") else {
            log(tag: self, message: "failed to send hello")
            return nil
        }

        guard let user = world.findUser(with: name) else {

            guard let user = registerUser(using: io, with: name, in: world) else {
                log(tag: self, message: "failed to register user")
                return nil
            }

            log(tag: self, message: "new user \(user.name) OUT")
            return DungeonHandler(user: user)
        }
        
        guard io.write(string: "What is your password? ") else {
            log(tag: self, message: "failed to write password prompt")
            return nil
        }
        
        guard let password = io.readLine() else {
            log(tag: self, message: "failed to read existing password")
            return nil
        }
        
        guard password == user.password else {
            guard io.write(string: "Incorrect password.  Goodbye.") else {
                log(tag: self, message: "failed to write incorrect password message")
                return nil
            }
            
            return nil
        }

        log(tag: self, message: "registered user \(user.name) OUT")
        return DungeonHandler(user: user)
    }
    
    func registerUser(using io: TerminalIO, with name: String, in world: World) -> User? {
        
        guard let password = readNewPassword(from: io) else {
            log(tag: self, message: "failed to read password")
            return nil
        }
        
        let user = User(name: name, password: password)
        
        world.update(user: user)
        
        return user
    }
    
    func readNewPassword(from io:TerminalIO) -> String? {
        
        while(true) {
            
            guard io.write(string: "Please choose a password: ") else {
                log(tag: self, message: "failed to write password prompt")
                return nil
            }
            
            guard let password = io.readLine() else {
                log(tag: self, message: "failed to read password")
                return nil
            }

            guard password.utf8.count >= 6 else {
                guard io.write(string: "Password must be 6 or more characters.\n") else {
                    log(tag: self, message: "failed to write password length error")
                    return nil
                }
                continue
            }
            
            guard io.write(string: "Confirm password: ") else {
                log(tag: self, message: "failed to write confirm password prompt")
                return nil
            }
            
            guard let confirm = io.readLine() else {
                log(tag: self, message: "failed to read confirm")
                return nil
            }
            
            if confirm == password {
                return password
            }

            guard io.write(string: "Passwords do not match.\n") else {
                log(tag: self, message: "failed to write confirm error")
                return nil
            }
        }
        
    }
    
    func readName(from io: TerminalIO) -> String? {
        
        while (true) {
        
            guard io.write(string: "Hello, please enter your name: ") else {
                log(tag: self, message: "failed to write prompt")
                return nil
            }
            
            guard let name = io.readLine() else {
                log(tag: self, message: "failed to read line")
                return nil
            }
            
            if nil != name.range(of: "^[a-z]+$", options: [ .regularExpression ]) {
                return name
            }

            guard io.write(string: "Sorry, names must be lower-case characters only.\n") else {
                log(tag: self, message: "failed to write user name error")
                return nil
            }
            
        }
        
    }
    
}
