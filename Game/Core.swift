struct Vector {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

struct Point {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    mutating func offset(by: Point) -> Point {
        x += by.x
        y += by.y
        return self
    }
}

struct Size {
    let width: Int
    let height: Int
}

struct Rectangle {
    let origin: Point
    let size: Size

    func collides(with other: Rectangle) -> Bool {
        let isHorizontalOverlap =
            origin.x < other.origin.x + other.size.width && origin.x + size.width > other.origin.x
        let isVerticalOverlap =
            origin.y < other.origin.y + other.size.height && origin.y + size.height > other.origin.y
        return isHorizontalOverlap && isVerticalOverlap
    }
}

enum Input {
    case buttonA
    case buttonB
    case blueButton

    init?(code: UInt32) {
        switch code {
            case 42:
                self = .blueButton
            case 12:
                self = .buttonA
            case 13:
                self = .buttonB
            default:
                return nil
        }
    }
}

struct Queue<Element> {
    private var store: [Element] = []

    mutating func enqueue(_ e: Element) {
        store.append(e)
    }

    mutating func dequeue() -> Element? {
        store.removeFirst()
    }

    func peek() -> Element? {
        store.first
    }

    var isFull: Bool {
        false
    }

    var isEmpty: Bool {
        store.isEmpty
    }
}
