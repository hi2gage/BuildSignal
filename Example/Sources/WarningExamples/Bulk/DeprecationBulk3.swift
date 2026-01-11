// MARK: - Bulk Deprecation Warnings Part 3

import Foundation

@available(*, deprecated, message: "Use NewHandler1 instead")
public class OldHandler1 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler2 instead")
public class OldHandler2 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler3 instead")
public class OldHandler3 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler4 instead")
public class OldHandler4 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler5 instead")
public class OldHandler5 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler6 instead")
public class OldHandler6 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler7 instead")
public class OldHandler7 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler8 instead")
public class OldHandler8 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler9 instead")
public class OldHandler9 { public init() {}; public func handle() {} }
@available(*, deprecated, message: "Use NewHandler10 instead")
public class OldHandler10 { public init() {}; public func handle() {} }

public class DeprecationUser3 {
    public init() {}

    public func use1() {
        OldHandler1().handle(); OldHandler2().handle(); OldHandler3().handle()
        OldHandler4().handle(); OldHandler5().handle(); OldHandler6().handle()
        OldHandler7().handle(); OldHandler8().handle(); OldHandler9().handle()
        OldHandler10().handle()
    }

    public func use2() {
        OldHandler1().handle(); OldHandler2().handle(); OldHandler3().handle()
        OldHandler4().handle(); OldHandler5().handle(); OldHandler6().handle()
        OldHandler7().handle(); OldHandler8().handle(); OldHandler9().handle()
        OldHandler10().handle()
    }

    public func use3() {
        OldHandler1().handle(); OldHandler2().handle(); OldHandler3().handle()
        OldHandler4().handle(); OldHandler5().handle(); OldHandler6().handle()
        OldHandler7().handle(); OldHandler8().handle(); OldHandler9().handle()
        OldHandler10().handle()
    }

    public func use4() {
        OldHandler1().handle(); OldHandler2().handle(); OldHandler3().handle()
        OldHandler4().handle(); OldHandler5().handle(); OldHandler6().handle()
        OldHandler7().handle(); OldHandler8().handle(); OldHandler9().handle()
        OldHandler10().handle()
    }
}
