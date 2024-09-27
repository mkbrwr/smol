public func startSwiftEngine() {
    let engine = SwiftEngine()

    engine.onCreate()

    while true {
        engine.onUpdate()
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
        red = UInt8(truncatingIfNeeded: (argb & 0x00_ff0000) >> 16)
        green = UInt8(truncatingIfNeeded: (argb & 0x00_00ff00) >> 8)
        blue = UInt8(truncatingIfNeeded: (argb & 0x00_0000ff))
    }
}

struct Point {
    let x: Int
    let y: Int
}

protocol Sprite {
    var width: Int { get }
    var height: Int { get }
    var pixels: [Pixel] { get set }
}

class SwiftLogo: Sprite {
    let width = 120
    let height = 50
    var pixels: [Pixel]
    init() {
        pixels = [Pixel].init(repeating: Pixel(argb: 0xffff_0000), count: width * height)
    }
}

/// X starts at lower left and goes Right
/// Y starts at lower left and goes Up
final class Screen {
    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    func draw(_ pixel: Pixel, at: Point) {
        screen_write_pixel(UInt32(at.x), UInt32(at.y), pixel.argb)
        screen_flush()
    }

    func fillScreen(repeating pixel: Pixel) {
        for x in 0..<width {
            for y in 0..<height {
                screen_write_pixel(UInt32(x), UInt32(y), pixel.argb)
            }
        }
        screen_flush()
    }
}

final class SwiftRenderer {
    private let screen: Screen

    init(screen: Screen) {
        self.screen = screen
    }

    func renderTestFrame() {
        screen.fillScreen(repeating: Pixel(argb: 0xffff_00ff))
    }

    func render(_ sprite: some Sprite, at origin: Point) {
        for x in 0..<sprite.width {
            for y in 0..<sprite.height {
                let idx = y + x * sprite.height
                screen.draw(sprite.pixels[idx], at: Point(x: origin.x + x, y: origin.y + y))
            }
        }
    }
}

final class SwiftEngine {
    private let renderer = SwiftRenderer(screen: Screen(width: 240, height: 320))

    init() {}

    func onCreate() {
    }

    func onUpdate() {
        let swiftLogo = SwiftLogo()
        renderer.render(swiftLogo, at: Point(x: 10, y: 40))
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
