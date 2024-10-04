enum Led {
    case red
    case green

    func toggle() {
        switch self {
        case .red:
            BSP_LED_Toggle(RED_LED)
        case .green:
            BSP_LED_Toggle(GREEN_LED)
        }
    }

    func on() {
        switch self {
        case .red:
            BSP_LED_On(RED_LED)
        case .green:
            BSP_LED_On(GREEN_LED)
        }
    }

    func off() {
        switch self {
        case .red:
            BSP_LED_Off(RED_LED)
        case .green:
            BSP_LED_Off(GREEN_LED)
        }
    }
}

enum RTT {
    //static func writeString(_ s: String) {
    //    SEGGER_RTT_WriteString(0, s)
    //}
}

enum HAL {
    static func getTick() -> Int {
        Int(HAL_GetTick())
    }
}
