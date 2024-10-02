public func startSwiftEngine() {
    let engine = SwiftEngine()
    var frameTimeMilliseconds = UInt32.max

    engine.onCreate()

    while true {
        frameTimeMilliseconds = HAL_GetTick()
        engine.onUpdate()
        frameTimeMilliseconds = HAL_GetTick() - frameTimeMilliseconds
        SEGGER_RTT_WriteString(0, "Frame time: \(frameTimeMilliseconds) ms.")
    }
}

class Entity {
    var id = UInt32.random(in: 0x0..<0xffff_ffff)
    let sprite: Sprite
    var position: Point
    var direction: Vector
    var body: Rectangle {
        Rectangle(origin: position, size: sprite.size)
    }

    init(sprite: Sprite, position: Point, direction: Vector) {
        self.sprite = sprite
        self.position = position
        self.direction = direction
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
    private let renderer = Renderer(
        screen: Screen(width: 240, height: 320, backgroundColor: Pixel(argb: 0x00_65737e)))

    let entities: [Entity] = [
        Entity(
            sprite: Sprite.swiftLogo, position: Point(x: 1, y: 1), direction: Vector(x: 2, y: 2)),
        Entity(
            sprite: Sprite.swiftLogo, position: Point(x: 80, y: 80), direction: Vector(x: -2, y: 2)),
        Entity(
            sprite: Sprite.swiftLogo, position: Point(x: 160, y: 160),
            direction: Vector(x: 2, y: -2)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 10, y: 40), direction: Vector(x: 3, y: 3)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 100, y: 40), direction: Vector(x: -3, y: 3)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 10, y: 140), direction: Vector(x: 3, y: -3)),
    ]

    func onCreate() {}

    func onUpdate() {
        renderer.screen.clear()
        for entity in entities {
            for otherEntity in entities {
                if otherEntity.id != entity.id {
                    if entity.collides(with: otherEntity) {
                        entity.reverseDirection()
                        otherEntity.reverseDirection()
                    }
                }
            }
            if entity.position.x + entity.sprite.size.width >= 240 || entity.position.x <= 0 {
                entity.direction.x = -entity.direction.x
            }
            if entity.position.y + entity.sprite.size.height >= 320 || entity.position.y <= 0 {
                entity.direction.y = -entity.direction.y
            }
            renderer.render(
                entity.sprite,
                at: entity.position.offset(by: Point(x: entity.direction.x, y: entity.direction.y)))
        }
        renderer.screen.flush()
        Led.green.toggle()
    }

    // TODO:
    //func onUserInput(input: [Input])
}
