// MARK: - Existential Warnings

import Foundation

public protocol ProtoX { func act() }
public protocol ProtoY { func act() }
public protocol ProtoZ { func act() }

public class ExistentialUser {
    public init() {}

    public var x: ProtoX?
    public var y: ProtoY?
    public var z: ProtoZ?

    public func takeX(_ p: ProtoX) { p.act() }
    public func takeY(_ p: ProtoY) { p.act() }
    public func takeZ(_ p: ProtoZ) { p.act() }

    public func returnX() -> ProtoX? { return x }
    public func returnY() -> ProtoY? { return y }
    public func returnZ() -> ProtoZ? { return z }

    public func arrays() {
        var arrX: [ProtoX] = []
        var arrY: [ProtoY] = []
        var arrZ: [ProtoZ] = []
        print(arrX, arrY, arrZ)
    }
}
