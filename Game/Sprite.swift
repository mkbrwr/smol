enum Sprite {
    case swiftLogo
    case alien
    case zombie

    var size: Size {
        switch self {
        case .swiftLogo:
            return .init(width: 50, height: 50)
        case .alien:
            return .init(width: 50, height: 50)
        case .zombie:
            return .init(width: 50, height: 50)
        }
    }

    private var defaultRotation: Rotation {
        switch self {
            case .swiftLogo: return .degree270
            case .alien: return .degree90
            case .zombie: return .degree270
        }
    }

    func pixel(at index: Int, rotation: Rotation = .none) -> Pixel {
        var rotation = if rotation == .none { defaultRotation } else { rotation };
        guard index < size.width * size.height else { return Pixel(argb: 0xff_ff_ff_ff) }
        var adjustedIndex = index
        let width = size.width
        let height = size.height

        switch rotation {
        case .none:
            break
        case .degree90:
            // Rotate 90 degrees clockwise
            let row = index / width
            let column = index % width
            adjustedIndex = (height - 1 - row) + column * height

        case .degree180:
            // Rotate 180 degrees clockwise
            let row = index / width
            let column = index % width
            adjustedIndex = (height - 1 - row) * width + (width - 1 - column)

        case .degree270:
            // Rotate 270 degrees clockwise (or 90 degrees counter-clockwise)
            let row = index / width
            let column = index % width
            adjustedIndex = row + (width - 1 - column) * height
        }

        return Pixel(argb: accessorFunc(UInt32(adjustedIndex)))
    }

    private var accessorFunc: (UInt32) -> (UInt32) {
        switch self {
            case .swiftLogo:
            return getSwiftLogoPixelDataAt
            case .alien:
            return getAlienPixelDataAt
            case .zombie:
            return getZombiePixelDataAt
        }
    }
}

enum Rotation {
    case none
    case degree90
    case degree180
    case degree270
}
