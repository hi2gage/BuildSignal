// MARK: - Deprecation Warnings

import Foundation

@available(*, deprecated, message: "Use NewAPI1")
public class OldAPI1 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI2")
public class OldAPI2 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI3")
public class OldAPI3 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI4")
public class OldAPI4 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI5")
public class OldAPI5 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI6")
public class OldAPI6 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI7")
public class OldAPI7 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI8")
public class OldAPI8 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI9")
public class OldAPI9 { public init() {}; public func run() {} }
@available(*, deprecated, message: "Use NewAPI10")
public class OldAPI10 { public init() {}; public func run() {} }

public class DeprecationUser {
    public init() {}

    public func use() {
        OldAPI1().run(); OldAPI2().run(); OldAPI3().run(); OldAPI4().run(); OldAPI5().run()
        OldAPI6().run(); OldAPI7().run(); OldAPI8().run(); OldAPI9().run(); OldAPI10().run()
    }

    public func useAgain() {
        OldAPI1().run(); OldAPI2().run(); OldAPI3().run(); OldAPI4().run(); OldAPI5().run()
        OldAPI6().run(); OldAPI7().run(); OldAPI8().run(); OldAPI9().run(); OldAPI10().run()
    }
}
