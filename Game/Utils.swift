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
}

enum RTT {
    static func writeString(_ s: String) {
        SEGGER_RTT_WriteString(0, s)
    }
}

enum HAL {
    static func getTick() -> Int {
        Int(HAL_GetTick())
    }
}
