public func startSwiftEngine() {
    let engine = SwiftEngine(200)

    engine.onCreate()

    while true {
        engine.onUpdate()
    }
}

// TODO: implement input
//public func handleInput(input: [Input]) {
//    engine.onUserInput(input: input)
//}

public enum Input {
    case buttonA
    case buttonB
}

class SwiftEngine {
    private var delay: UInt32 = 100
    private let delay2: UInt32

    init(_ delay: UInt32) {
        self.delay2 = delay
    }

    func onCreate() {
    }

    func onUpdate() {
        HAL_Delay(self.delay)
        BSP_LED_Toggle(LED3)
        HAL_Delay(self.delay2)
    }

    func onUserInput(input: [Input]) {

    }
}
