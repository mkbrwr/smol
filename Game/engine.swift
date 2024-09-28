public func startSwiftEngine() {
    let engine = SwiftEngine()

    engine.onCreate()

    while true {
        engine.onUpdate()
    }
}

typealias ColorComponent = UInt8

class Pixel {
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

protocol Sprite {
    var width: Int { get }
    var height: Int { get }
    subscript(index: Int) -> Pixel? { get }
}

class SwiftLogo: Sprite {
    let width = 50
    let height = 50

    var pixels: [Pixel] = []

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
        fill(repeating: backgroundColor)
    }

    func clear() {
        fill(repeating: backgroundColor)
    }

    func draw(_ pixel: Pixel, at: Point) {
        screen_write_pixel(UInt32(at.x), UInt32(at.y), pixel.argb)
    }

    func fill(repeating pixel: Pixel) {
        for x in 0..<width {
            for y in 0..<height {
                screen_write_pixel(UInt32(x), UInt32(y), pixel.argb)
            }
        }
    }

    func flush() {
        screen_flush()
    }
}

final class SwiftRenderer {
    private let screen: Screen

    init(screen: Screen) {
        self.screen = screen
    }

    func renderTestFrame() {
        screen.fill(repeating: Pixel(argb: 0xffff_00ff))
    }

    func render(_ sprite: some Sprite, at origin: Point) {
        screen.clear()
        for y in 0..<sprite.height {
            for x in 0..<sprite.width {
                let idx = y + x * sprite.width
                if let pixel = sprite[idx] {
                    screen.draw(pixel, at: Point(x: origin.x + x, y: origin.y + y))
                }
            }
        }
        screen.flush()
    }
}

final class SwiftEngine {
    private let renderer = SwiftRenderer(
        screen: Screen(width: 240, height: 320, backgroundColor: Pixel(argb: 0xff00_0000)))

    let swiftLogo = SwiftLogo()
    var logoOrigin = Point(x: 10, y: 40)
    var logoSpeedX = 0
    var logoSpeedY = 0

    func onCreate() {
        logoSpeedX = 2
        logoSpeedY = 2
    }

    func onUpdate() {
        if logoOrigin.x + swiftLogo.width >= 240 || logoOrigin.x <= 0 {
            logoSpeedX = -logoSpeedX
        }
        if logoOrigin.y + swiftLogo.height >= 320 || logoOrigin.y <= 0 {
            logoSpeedY = -logoSpeedY
        }
        renderer.render(swiftLogo, at: logoOrigin.offset(by: Point(x: logoSpeedX, y: logoSpeedY)))
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
