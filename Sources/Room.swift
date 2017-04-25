
import Foundation

class Room: Equatable, CustomStringConvertible {

    var description: String {
        return title
    }

    var exits = [String: Room]()

    let id = NSUUID().uuidString
    let title: String

    init(title: String) {
        self.title = title
    }

    public static func ==(lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id
    }

}
