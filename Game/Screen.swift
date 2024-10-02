typealias ColorComponent = UInt8

struct Pixel {
    let red: ColorComponent
    let green: ColorComponent
    let blue: ColorComponent

    var argb: UInt32 {
        if red == 0 && green == 0 && blue == 0 {
            return UInt32(0x00_00_00_00)  // transparent
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
        screen_fill_foreground(0x0000_0000)
    }

    func draw(_ pixel: Pixel, at: Point) {
        screen_write_pixel_foreground(UInt32(at.x), UInt32(at.y), pixel.argb)
    }

    func flush() {
        screen_flush_blend()
    }
}
