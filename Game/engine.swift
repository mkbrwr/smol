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

    func render(_ frame: Frame) {
        for x in 0..<screenWidth {
            for y in 0..<screenHeight {
                let pixel = getSwiftLogoPixelDataAt(UInt32(y % 50), UInt32(x % 50))
                screen_write_pixel(
                    UInt32(x),
                    UInt32(y),
                    pixel
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
