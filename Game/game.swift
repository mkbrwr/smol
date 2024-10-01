public func startSwiftEngine() {
    class CDontMangleMe {}
    var c: CDontMangleMe
    c = CDontMangleMe()

    for _ in 0..<20_000 {
        c = CDontMangleMe()
    }

    while true {
        HAL_Delay(1000)
        BSP_LED_Toggle(0)
        HAL_Delay(1000)
    }
}
