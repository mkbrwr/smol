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

class Point {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    func offset(by: Point) -> Point {
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

protocol Sprite {
    var width: Int { get }
    var height: Int { get }
    subscript(index: Int) -> Pixel? { get }
}

class SwiftLogo: Sprite {
    let width = 50
    let height = 50

    private(set) var pixels: [Pixel] = []

    init() {
        for index in 0..<width * height {
            pixels.append(Pixel(argb: getSwiftLogoPixelDataAt(UInt32(index))))
        }
    }

    subscript(index: Int) -> Pixel? {
        guard index < width * height else { return nil }
        return pixels[index]
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

    func render(_ sprite: some Sprite, at origin: Point) {
        for y in 0..<sprite.height {
            for x in 0..<sprite.width {
                let idx = y + x * sprite.width
                if let pixel = sprite[idx] {
                    screen.draw(pixel, at: Point(x: origin.x + x, y: origin.y + y))
                }
            }
        }
    }
}

class Vector {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

final class SwiftEngine {
    private let renderer = SwiftRenderer(
        screen: Screen(width: 240, height: 320, backgroundColor: Pixel(argb: 0xff00_0000)))

    let logos = [
        (sprite: SwiftLogo(), origin: Point(x: 10, y: 40), direction: Vector(x: 2, y: 2)),
        (sprite: SwiftLogo(), origin: Point(x: 100, y: 40), direction: Vector(x: -2, y: 2)),
        (sprite: SwiftLogo(), origin: Point(x: 10, y: 140), direction: Vector(x: 2, y: -2)),
        (sprite: SwiftLogo(), origin: Point(x: 10, y: 40), direction: Vector(x: 3, y: 3)),
        (sprite: SwiftLogo(), origin: Point(x: 100, y: 40), direction: Vector(x: -3, y: 3)),
        (sprite: SwiftLogo(), origin: Point(x: 10, y: 140), direction: Vector(x: 3, y: -3)),
    ]

    func onCreate() {}

    func onUpdate() {
        renderer.screen.clear()
        for logo in logos {
            if logo.origin.x + logo.sprite.width >= 240 || logo.origin.x <= 0 {
                logo.direction.x = -logo.direction.x
            }
            if logo.origin.y + logo.sprite.height >= 320 || logo.origin.y <= 0 {
                logo.direction.y = -logo.direction.y
            }
            renderer.render(
                logo.sprite,
                at: logo.origin.offset(by: Point(x: logo.direction.x, y: logo.direction.y)))
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
