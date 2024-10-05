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

/// X starts at lower left and goes Right
/// Y starts at lower left and goes Up
final class Screen {
    let width: Int
    let height: Int
    var background: Pixel = Pixel(argb: 0xff000000);

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    func add(_ sprite: Sprite, at origin: Point, rotation: Rotation = .none) {
        for y in 0..<sprite.size.height {
            for x in 0..<sprite.size.width {
                let idx = y + x * sprite.size.width
                let pixel = sprite.pixel(at: idx, rotation: rotation)
                let point = Point(x: origin.x + x, y: origin.y + y)
                guard 0..<width ~= point.x && 0..<height ~= point.y else {
                    continue
                }
                draw(pixel, at: point)
            }
        }
    }

    func clear() {
        screen_clear(background.argb);
    }

    func flush() {
        screen_flush();
    }

    private func draw(_ pixel: Pixel, at: Point) {
        screen_write_pixel(UInt32(at.x), UInt32(at.y), pixel.argb);
    }
}
