public protocol SomethingSomething {
    func fizBuzz() -> Bool
}

extension SomethingSomething {
    public func fizBuzz() -> Bool {
        true
    }
}

public struct Strooct {
    public func myBazFunc() {
        for w in 0..<50 {
            for h in 0..<50 {
                let pixel = getPixelDataAt(UInt32(w), UInt32(h))

                let a = UInt8(truncatingIfNeeded: pixel & 0xFF00_0000 >> 24)
                let r = UInt8(truncatingIfNeeded: pixel & 0x00FF_0000 >> 16)
                let g = UInt8(truncatingIfNeeded: pixel & 0x0000_FF00 >> 8)
                let b = UInt8(truncatingIfNeeded: pixel & 0x0000_00FF)

                let pixelColor = ScreenColor(
                    a: CChar(bitPattern: a),  // blue
                    r: CChar(bitPattern: r),  // green
                    g: CChar(bitPattern: g),  // red
                    b: CChar(bitPattern: b)  // alpha
                )
                screen_write_pixel(UInt32(h), UInt32(w), pixelColor, 1.0)
            }
            screen_flush()
        }
    }

    public func myFooFunc() -> Int {
        screen_clear(
            ScreenColor(
                a: CChar(bitPattern: 0xFF),
                r: CChar(bitPattern: 0xFF),
                g: 0x00,
                b: CChar(bitPattern: 0xFF)
            )
        )
        screen_flush()
        BSP_LED_Toggle(LED3)
        return 0
    }

    public func myBarFunc() -> Int {
        screen_clear(
            ScreenColor(
                a: CChar(bitPattern: 0xFF),
                r: 0x00,
                g: CChar(bitPattern: 0xFF),
                b: 0x00
            )
        )
        screen_flush()
        BSP_LED_Toggle(LED3)
        return 0
    }
}

extension Strooct: SomethingSomething {}
