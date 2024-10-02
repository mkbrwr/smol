let GREEN = UInt32(0)
let RED   = UInt32(1)

public func startSwiftEngine() {
    class CDontMangleMe {
        let x: UInt32

        init() {
            if Bool.random() {
                x = 0x1122_3344
            } else {
                x = 0x5566_7788
            }
        }
    }
    var c: CDontMangleMe
    c = CDontMangleMe()

    for _ in 0..<200_000 {
        c = CDontMangleMe()
    }

    while true {
        HAL_Delay(500)
        BSP_LED_Toggle(GREEN)
        HAL_Delay(500)
    }
}
