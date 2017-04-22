
class LoginHandler: CommandHandler {
    
    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        log(tag: self, message: "handle IN")
        
        guard let name = readName(from: io) else {
            log(tag: self, message: "failed to read name OUT")
            return nil
        }

        guard io.print("Hello, \(name).  ") else {
            log(tag: self, message: "failed to send hello")
            return nil
        }

        var user:User! = world.findUser(with: name)
        if user == nil {

            guard let u = registerUser(using: io, with: name, in: world) else {
                log(tag: self, message: "failed to register user")
                return nil
            }

            user = u
            log(tag: self, message: "new user \(user.name) OUT")

        } else { // authenticate user

            guard io.print("What is your password? ") else {
                log(tag: self, message: "failed to write password prompt")
                return nil
            }

            guard let password = io.readLine() else {
                log(tag: self, message: "failed to read existing password")
                return nil
            }

            guard password == user.password else {
                guard io.print("Incorrect password.  Goodbye.") else {
                    log(tag: self, message: "failed to write incorrect password message")
                    return nil
                }

                return nil
            }

        }

        log(tag: self, message: "registered user \(user.name) OUT")
        ConnectionProperties.instance().user = user
        return DungeonHandler()
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
            
            guard io.print("Please choose a password: ") else {
                log(tag: self, message: "failed to write password prompt")
                return nil
            }
            
            guard let password = io.readLine() else {
                log(tag: self, message: "failed to read password")
                return nil
            }

            guard password.utf8.count >= 6 else {
                guard io.print("Password must be 6 or more characters.\n") else {
                    log(tag: self, message: "failed to write password length error")
                    return nil
                }
                continue
            }
            
            guard io.print("Confirm password: ") else {
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

            guard io.print("Passwords do not match.\n") else {
                log(tag: self, message: "failed to write confirm error")
                return nil
            }
        }
        
    }
    
    func readName(from io: TerminalIO) -> String? {
        
        while (true) {
        
            guard io.print("Hello, please enter your name: ") else {
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

            guard io.print("Sorry, names must be lower-case characters only.\n") else {
                log(tag: self, message: "failed to write user name error")
                return nil
            }
            
        }
        
    }
    
}
