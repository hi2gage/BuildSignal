// MARK: - Bulk Frozen Enum Warnings

import Foundation

@frozen internal enum FrozenInternal1 { case a, b, c }
@frozen internal enum FrozenInternal2 { case a, b, c }
@frozen internal enum FrozenInternal3 { case a, b, c }
@frozen internal enum FrozenInternal4 { case a, b, c }
@frozen internal enum FrozenInternal5 { case a, b, c }
@frozen internal enum FrozenInternal6 { case a, b, c }
@frozen internal enum FrozenInternal7 { case a, b, c }
@frozen internal enum FrozenInternal8 { case a, b, c }
@frozen internal enum FrozenInternal9 { case a, b, c }
@frozen internal enum FrozenInternal10 { case a, b, c }
@frozen internal enum FrozenInternal11 { case a, b, c }
@frozen internal enum FrozenInternal12 { case a, b, c }
@frozen internal enum FrozenInternal13 { case a, b, c }
@frozen internal enum FrozenInternal14 { case a, b, c }
@frozen internal enum FrozenInternal15 { case a, b, c }
@frozen internal enum FrozenInternal16 { case a, b, c }
@frozen internal enum FrozenInternal17 { case a, b, c }
@frozen internal enum FrozenInternal18 { case a, b, c }
@frozen internal enum FrozenInternal19 { case a, b, c }
@frozen internal enum FrozenInternal20 { case a, b, c }

public class FrozenEnumUser {
    public init() {}

    public func use() {
        let _ = FrozenInternal1.a
        let _ = FrozenInternal2.a
        let _ = FrozenInternal3.a
        let _ = FrozenInternal4.a
        let _ = FrozenInternal5.a
        let _ = FrozenInternal6.a
        let _ = FrozenInternal7.a
        let _ = FrozenInternal8.a
        let _ = FrozenInternal9.a
        let _ = FrozenInternal10.a
    }
}
