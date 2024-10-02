final class Renderer {
    let screen: Screen

    init(screen: Screen) {
        self.screen = screen
    }

    func render(_ sprite: Sprite, at origin: Point) {
        for y in 0..<sprite.size.height {
            for x in 0..<sprite.size.width {
                let idx = y + x * sprite.size.width
                let pixel = sprite[idx]
                let point = Point(x: origin.x + x, y: origin.y + y)
                guard
                    0 < point.x && point.x < screen.width && 0 < point.y && point.y < screen.height
                else {
                    continue
                }
                screen.draw(pixel, at: point)
            }
        }
    }
}
