public func startSwiftEngine() {
    let engine = SwiftEngine()
    //var frameTimeMilliseconds = UInt32.max

    engine.onCreate()

    while true {
        //frameTimeMilliseconds = HAL_GetTick()
        engine.onUpdate()
        //frameTimeMilliseconds = HAL_GetTick() - frameTimeMilliseconds
        //SEGGER_RTT_WriteString(0, "Frame time: \(frameTimeMilliseconds) ms.")
    }
}

typealias ColorComponent = UInt8

struct Pixel {
    let red: ColorComponent
    let green: ColorComponent
    let blue: ColorComponent

    var argb: UInt32 {
        if red == 0 && green == 0 && blue == 0 {
            return UInt32(0x00_00_00_00) // transparent
        }
        var uint32 = UInt32(0xff_00_00_00)
        uint32 |= UInt32(red) << 16
        uint32 |= UInt32(green) << 8
        uint32 |= UInt32(blue)
        return uint32
    }

    init(argb: UInt32) {
        red = UInt8(truncatingIfNeeded: (argb & 0x00_ff0000) >> 16)
        green = UInt8(truncatingIfNeeded: (argb & 0x00_00ff00) >> 8)
        blue = UInt8(truncatingIfNeeded: (argb & 0x00_0000ff))
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
        let isHorizontalOverlap = origin.x < other.origin.x + other.size.width && origin.x + size.width > other.origin.x
        let isVerticalOverlap = origin.y < other.origin.y + other.size.height && origin.y + size.height > other.origin.y
        return isHorizontalOverlap && isVerticalOverlap
    }
}

enum Sprite {
    case swiftLogo

    var size: Size {
        switch self {
        case .swiftLogo:
        return .init(width: 50, height: 50)
        }
    }

    subscript(index: Int) -> Pixel {
        store.pixels(for: self)[index]
    }
}

fileprivate let store = SpriteStore()

struct SpriteStore {
    var contents: [Sprite] = []
    private var pixels: [Pixel] = []

    init() {
        loadSwiftLogo()
    }

    private mutating func loadSwiftLogo() {
        let swiftLogo = Sprite.swiftLogo
        contents.append(swiftLogo)
        for index in 0..<swiftLogo.size.width * swiftLogo.size.height {
            pixels.append(Pixel(argb: getSwiftLogoPixelDataAt(UInt32(index))))
        }
    }

    func pixels(for sprite: Sprite) -> ArraySlice<Pixel> {
        guard let spriteIndex = contents.firstIndex(of: sprite) else { fatalError("Sprite not loaded into memory!") }
        return pixels[spriteIndex..<sprite.size.width * sprite.size.height]
    }
}

/// X starts at lower left and goes Right
/// Y starts at lower left and goes Up
final class Screen {
    let width: Int
    let height: Int
    let backgroundColor: Pixel

    init(width: Int, height: Int, backgroundColor: Pixel) {
        self.width = width
        self.height = height
        self.backgroundColor = backgroundColor
        screen_init()
        screen_fill_background(backgroundColor.argb)
    }

    func clear() {
        screen_fill_foreground(0x00000000)
    }

    func draw(_ pixel: Pixel, at: Point) {
        screen_write_pixel_foreground(UInt32(at.x), UInt32(at.y), pixel.argb)
    }

    func flush() {
        screen_flush_blend()
    }
}

final class SwiftRenderer {
    let screen: Screen

    init(screen: Screen) {
        self.screen = screen
    }

    func render(_ sprite: Sprite, at origin: Point) {
        for y in 0..<sprite.size.height {
            for x in 0..<sprite.size.width {
                let idx = y + x * sprite.size.width
                let pixel = sprite[idx]
                screen.draw(pixel, at: Point(x: origin.x + x, y: origin.y + y))
            }
        }
    }
}

struct Vector {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

class Entity {
    var id = UInt32.random(in: 0x0..<0xffffffff)
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
    private let renderer = SwiftRenderer(
        screen: Screen(width: 240, height: 320, backgroundColor: Pixel(argb: 0x00_65737e)))

    let entities: [Entity] = [
        Entity(sprite: Sprite.swiftLogo, position: Point(x: 1, y: 1), direction: Vector(x: 2, y: 2)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 80, y: 80), direction: Vector(x: -2, y: 2)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 160, y: 160), direction: Vector(x: 2, y: -2)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 10, y: 40), direction: Vector(x: 3, y: 3)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 100, y: 40), direction: Vector(x: -3, y: 3)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 10, y: 140), direction: Vector(x: 3, y: -3)),
    ]

    func onCreate() {}

    func onUpdate() {
        renderer.screen.clear()
        for entity in entities {
            //for otherEntity in entities {
            //    if otherEntity.id != entity.id {
            //        if entity.collides(with: otherEntity) {
            //            entity.reverseDirection()
            //            otherEntity.reverseDirection()
            //        }
            //    }
            //}
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

// Utils
enum Led {
    case red
    case green

    func toggle() {
        switch self {
        case .red:
            BSP_LED_Toggle(RED_LED)
        case .green:
            BSP_LED_Toggle(GREEN_LED)
        }
    }
}
