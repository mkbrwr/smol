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

typealias ColorComponent = UInt8

struct Pixel {
    let red: ColorComponent
    let green: ColorComponent
    let blue: ColorComponent

    var argb: UInt32 {
        var uint32 = UInt32(0xff_00_00_00)
        uint32 |= UInt32(red) << 16
        uint32 |= UInt32(green) << 8
        uint32 |= UInt32(blue)
        return uint32
    }

    init(argb: UInt32) {
        //SEGGER_RTT_WriteString(0, "Pixel init")
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
    private var backgroundColor: Pixel = Pixel(argb: 0xffff_ffff)

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    convenience init(width: Int, height: Int, backgroundColor: Pixel) {
        self.init(width: width, height: height)
        self.backgroundColor = backgroundColor
        screen_clear(backgroundColor.argb)
    }

    func clear() {
        screen_clear(backgroundColor.argb)
    }

    func clear(area rectangle: Rectangle) {
        for x in rectangle.origin.x..<rectangle.origin.y + rectangle.size.width {
            for y in rectangle.origin.y..<rectangle.origin.y + rectangle.size.height {
                screen_write_pixel(UInt32(x), UInt32(y), backgroundColor.argb)
            }
        }
    }

    func draw(_ pixel: Pixel, at: Point) {
        screen_write_pixel(UInt32(at.x), UInt32(at.y), pixel.argb)
    }

    func flush() {
        screen_flush()
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
    let sprite: Sprite
    var position: Point
    var direction: Vector

    init(sprite: Sprite, position: Point, direction: Vector) {
        self.sprite = sprite
        self.position = position
        self.direction = direction
    }
}

final class SwiftEngine {
    private let renderer = SwiftRenderer(
        screen: Screen(width: 240, height: 320, backgroundColor: Pixel(argb: 0xff00_0000)))

    var entities: [Entity] = [
        Entity(sprite: Sprite.swiftLogo, position: Point(x: 10, y: 40), direction: Vector(x: 2, y: 2)),
        Entity(sprite: Sprite.swiftLogo, position: Point(x: 100, y: 40), direction: Vector(x: -2, y: 2)),
        Entity(sprite: Sprite.swiftLogo, position: Point(x: 10, y: 140), direction: Vector(x: 2, y: -2)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 10, y: 40), direction: Vector(x: 3, y: 3)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 100, y: 40), direction: Vector(x: -3, y: 3)),
        //Entity(sprite: Sprite.swiftLogo, position: Point(x: 10, y: 140), direction: Vector(x: 3, y: -3)),
    ]

    func onCreate() {}

    func onUpdate() {
        renderer.screen.clear()
        for entity in entities {
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
