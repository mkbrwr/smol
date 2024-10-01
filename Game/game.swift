public func startSwiftEngine() {
    while true {
        HAL_Delay(1000)
        BSP_LED_Toggle(0)
        HAL_Delay(1000)
    }
}
