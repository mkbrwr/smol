private let store = SpriteStore()

enum Sprite {
    case swiftLogo

    var size: Size {
        switch self {
        case .swiftLogo:
            return .init(width: 50, height: 50)
        }
    }

    subscript(index: Int) -> Pixel {
        store.pixels(for: self)[index]
    }
}

struct SpriteStore {
    var contents: [Sprite] = []
    private var pixels: [Pixel] = []

    init() {
        loadSwiftLogo()
    }

    private mutating func loadSwiftLogo() {
        let swiftLogo = Sprite.swiftLogo
        contents.append(swiftLogo)
        for index in 0..<swiftLogo.size.width * swiftLogo.size.height {
            pixels.append(Pixel(argb: getSwiftLogoPixelDataAt(UInt32(index))))
        }
    }

    func pixels(for sprite: Sprite) -> ArraySlice<Pixel> {
        guard let spriteIndex = contents.firstIndex(of: sprite) else {
            fatalError("Sprite not loaded into memory!")
        }
        return pixels[spriteIndex..<sprite.size.width * sprite.size.height]
    }
}
