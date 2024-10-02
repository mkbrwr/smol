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
