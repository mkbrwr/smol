public func startSwiftEngine() {
    class CDontMangleMe {
        let x = UInt32.random(in: 0x00..<0xffff_ffff)
    }
    var c: CDontMangleMe
    c = CDontMangleMe()

    for _ in 0..<1_000 {
        c = CDontMangleMe()
    }

    while true {
        HAL_Delay(1000)
        BSP_LED_Toggle(0)
        HAL_Delay(1000)
    }
}
