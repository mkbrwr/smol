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

    var uint32: UInt32 {
        var uint32 = UInt32(0xff_00_00_00)
        uint32 |= UInt32(red) << 16
        uint32 |= UInt32(green) << 8
        uint32 |= UInt32(blue)
        return uint32
    }
}

struct Frame {
    let pixels: [Pixel]

    init(pixels: [Pixel]) {
        self.pixels = pixels
    }
}

final class SwiftRenderer {
    private let screenWidth: UInt
    private let screenHeight: UInt

    init(screenWidth: UInt, screenHeight: UInt) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }
    private var testVar = 0
    func render(_ frame: Frame) {
        let pixel: Pixel
        switch testVar {
        case 0:
            pixel = Pixel(red: 0xff, green: 0x00, blue: 0x00)
        case 1:
            pixel = Pixel(red: 0x00, green: 0xff, blue: 0x00)
        case 2:
            pixel = Pixel(red: 0x00, green: 0x00, blue: 0xff)
        default:
            fatalError()
        }
        testVar = (testVar + 1) % 3
        for x in 0..<screenWidth {
            for y in 0..<screenHeight {
                screen_write_pixel(
                    UInt32(x),
                    UInt32(y),
                    pixel.uint32
                )
            }
        }
        screen_flush()
    }
}

final class SwiftEngine {
    private let renderer = SwiftRenderer(screenWidth: 240, screenHeight: 320)

    init() {}

    func onCreate() {
    }

    func onUpdate() {
        let frame = Frame(pixels: [])
        renderer.render(frame)
    }

    // TODO:
    //func onUserInput(input: [Input])
}
