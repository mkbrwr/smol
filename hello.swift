public protocol SomethingSomething {
    func fizBuzz() -> Bool
}

extension SomethingSomething {
    public func fizBuzz() -> Bool {
        true
    }
}

public struct Strooct {
    public func myFooFunc() -> Int {
        return 10
    }
}

extension Strooct: SomethingSomething {}
