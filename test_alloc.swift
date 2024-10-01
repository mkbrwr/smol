let startAddress = UInt(0x2001_8000)
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
    if offset >= 0xC000 {
        fatalError()
    }
    ptr.pointee = result
    return 0
}

@_cdecl("free")
public func free(_ ptr: UnsafeMutableRawPointer?) {
    BSP_LED_On(1)
    BSP_LED_On(2)
    while true {}
}
func fatalError() -> Never {
    while true {
        HAL_Delay(50)
        BSP_LED_Toggle(1)
        HAL_Delay(50)
    }  // or something something
}
