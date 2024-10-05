public func startSwiftEngine() {
    let engine = SwiftEngine()
    var frameTimeMilliseconds = Int.max

    while true {
        frameTimeMilliseconds = HAL.getTick()
        engine.onUpdate()
        frameTimeMilliseconds = HAL.getTick() - frameTimeMilliseconds
        if frameTimeMilliseconds > 33 {
            Led.red.on()
        } else {
            Led.red.off()
        }
    }
}

var inputs = Queue<Input>()

public func handleUserInput(_ code: UInt32) {
    if let input = Input(code: code) {
        inputs.enqueue(input)
    }
}

final class Entity {
    var id = UInt8.random(in: 1...255)
    let sprite: Sprite
    var position: Point {
        didSet {
            self.body = Rectangle(origin: position, size: sprite.size)
        }
    }
    var direction: Vector
    var body: Rectangle
    var markedForDeletion = false

    init(sprite: Sprite, position: Point, direction: Vector) {
        self.sprite = sprite
        self.position = position
        self.direction = direction
        self.body = Rectangle(origin: position, size: sprite.size)
    }

    func collides(with other: Entity) -> Bool {
        body.collides(with: other.body)
    }

    func reverseDirection() {
        direction.x *= -1
        direction.y *= -1
    }
}

final class SwiftEngine {
    private let screen = Screen(width: 240, height: 320)

    var entities: [Entity] = [
        Entity(sprite: Sprite.swiftLogo, position: Point(x: 1, y: 1), direction: Vector(x: 2, y: 2))
    ]

    func onUpdate() {
        entities = entities.filter { $0.markedForDeletion  == false }
        screen.clear()
        while !inputs.isEmpty {
            reactToInput(inputs.dequeue()!)
        }
        for entity in entities {
            for otherEntity in entities[1...] {
                if entities[0].collides(with: otherEntity) {
                    otherEntity.markedForDeletion = true
                }
            }
            if entity.position.x + entity.sprite.size.width >= 240 || entity.position.x <= 0 {
                entity.direction.x = -entity.direction.x
            }
            if entity.position.y + entity.sprite.size.height >= 320 || entity.position.y <= 0 {
                entity.direction.y = -entity.direction.y
            }
            screen.add(
                entity.sprite,
                at: entity.position.offset(by: Point(x: entity.direction.x, y: entity.direction.y)),
                rotation: .none)
        }
        screen.flush()
    }

    func reactToInput(_ input: Input) {
        switch input {
        case .blueButton:
            let sprite: Sprite = if Bool.random() { Sprite.alien } else { .zombie }
            let origin = Point(x: Int.random(in: 1...180), y: Int.random(in: 1...260))
            let direction = Vector(x: Int.random(in: -2...2), y: Int.random(in: -2...2))
            let entity = Entity(sprite: sprite, position: origin, direction: direction)
            entities.append(entity)
        default:
            return
            //RTT.writeString("default input handler")
        }
    }
}
