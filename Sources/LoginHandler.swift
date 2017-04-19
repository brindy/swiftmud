
class LoginHandler: CommandHandler {
    
    func handle(io: TerminalIO, world: World) -> CommandHandler? {
        print("LoginHandler", "handle IN")
        
        guard let name = readName(from: io) else {
            print("LoginHandler", "failed to read name OUT")
            return nil
        }

        guard io.write(string: "Hello, \(name).  ") else {
            print("LoginHandler", "failed to send hello")
            return nil
        }

        guard let user = world.findUser(with: name) else {

            guard let user = registerUser(using: io, with: name, in: world) else {
                print("LoginHandler", "failed to register user")
                return nil
            }
            
            print("LoginHandler", "new user \(user.name) OUT")
            return NavigationHandler(user: user)
        }
        
        // TODO prompt for password
        
        guard let password = io.readLine() else {
            print("LoginHandler", "failed to read existing password")
            return nil
        }
        
        guard password == user.password else {
            guard io.write(string: "Incorrect password.  Goodbye.") else {
                print("LoginHandler", "failed to write incorrect password message")
                return nil
            }
            
            return nil
        }
        
        print("LoginHandler", "registered user \(user.name) OUT")
        return NavigationHandler(user: user)
    }
    
    func registerUser(using io: TerminalIO, with name: String, in world: World) -> User? {
        
        guard let password = readNewPassword(from: io) else {
            print("LoginHandler", "failed to read password")
            return nil
        }
        
        let user = User(name: name, password: password)
        
        world.update(user: user)
        
        return user
    }
    
    func readNewPassword(from io:TerminalIO) -> String? {
        
        while(true) {
            
            guard io.write(string: "Please choose a password: ") else {
                print("LoginHandler", "failed to write password prompt")
                return nil
            }
            
            guard let password = io.readLine() else {
                print("LoginHandler", "failed to read password")
                return nil
            }

            print("password is \(password)")
            
            guard password.utf8.count >= 6 else {
                guard io.write(string: "Password must be 6 or more characters.\n") else {
                    print("LoginHandler", "failed to write password length error")
                    return nil
                }
                continue
            }
            
            guard io.write(string: "Confirm password: ") else {
                print("LoginHandler", "failed to write confirm password prompt")
                return nil
            }
            
            guard let confirm = io.readLine() else {
                print("LoginHandler", "failed to read confirm")
                return nil
            }
            
            if confirm == password {
                return password
            }

            guard io.write(string: "Passwords do not match.\n") else {
                print("LoginHandler", "failed to write confirm error")
                return nil
            }
        }
        
    }
    
    func readName(from io: TerminalIO) -> String? {
        
        while (true) {
        
            guard io.write(string: "Hello, please enter your name: ") else {
                print("LoginHandler", "failed to write prompt")
                return nil
            }
            
            guard let name = io.readLine() else {
                print("LoginHandler", "failed to read line")
                return nil
            }
            
            if nil != name.range(of: "^[a-z]+$", options: [ .regularExpression ]) {
                return name
            }

            guard io.write(string: "Sorry, names must be lower-case characters only.\n") else {
                print("LoginHandler", "failed to write user name error")
                return nil
            }
            
        }
        
    }
    
}
