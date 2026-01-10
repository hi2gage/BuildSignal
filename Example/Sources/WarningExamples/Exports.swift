// MARK: - WarningExamples Module

// This is the main module file.
// Build this package with: swift build
// The build process will generate many warnings for testing BuildSignal.

import Foundation

/// Main entry point for the WarningExamples library.
public struct WarningExamples {
    public init() {}

    /// Returns information about the warning examples package
    public func info() -> String {
        return "WarningExamples - A Swift package designed to generate compiler warnings for testing."
    }
}
