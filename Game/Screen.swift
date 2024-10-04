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

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    func add(_ sprite: Sprite, at origin: Point) {
        for y in 0..<sprite.size.height {
            for x in 0..<sprite.size.width {
                let idx = y + x * sprite.size.width
                let pixel = sprite[idx]
                let point = Point(x: origin.x + x, y: origin.y + y)
                guard 0..<width ~= point.x && 0..<height ~= point.y else {
                    continue
                }
                draw(pixel, at: point)
            }
        }
    }

    func showFrame() {
        show_frame()
    }

    private func draw(_ pixel: Pixel, at: Point) {
        screen_write_pixel(UInt32(at.x), UInt32(at.y), pixel.argb)
    }
}
