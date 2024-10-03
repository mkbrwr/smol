enum Sprite {
    case swiftLogo

    var size: Size {
        switch self {
        case .swiftLogo:
            return .init(width: 50, height: 50)
        }
    }

    subscript(index: Int) -> Pixel {
        guard index < size.width * size.height else { return Pixel(argb: 0xff_ff_ff_ff) }
        return Pixel(argb: accessorFunc(UInt32(index)))
    }

    private var accessorFunc: (UInt32) -> (UInt32) {
        switch self {
            case .swiftLogo:
            return getSwiftLogoPixelDataAt
        }
    }
}
