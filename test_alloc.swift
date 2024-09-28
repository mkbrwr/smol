let startAddress = UInt(0xD02A_B000)
var memoryArea = UnsafeMutableRawPointer(bitPattern: startAddress)!
var offset = 0

@_cdecl("posix_memalign")
public func posix_memalign(
    _ ptr: UnsafeMutablePointer<UnsafeMutableRawPointer?>, _ alignment: Int, _ size: Int
) -> CInt {
    // always align to 16 for simplicity
    var size = size + 16 - 1
    size = size - (size % 16)
    let result = memoryArea + offset
    offset += size
    if offset >= 50000000 {
        fatalError()
    }
    ptr.pointee = result
    return 0
}

@_cdecl("free")
public func free(_ ptr: UnsafeMutableRawPointer?) {
    // noop
}
func fatalError() -> Never {
    while true {
        HAL_Delay(100)
        BSP_LED_Toggle(RED_LED)
        HAL_Delay(100)
    }  // or something something
}
