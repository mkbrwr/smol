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
