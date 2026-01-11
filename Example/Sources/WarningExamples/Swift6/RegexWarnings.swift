// MARK: - Regex Warnings - Swift 5.7+

import Foundation

// Bare slash regex literal warnings (BareSlashRegexLiterals feature)
public class RegexWarnings {
    public init() {}

    // Regex patterns that might have issues
    public func regexPatterns() {
        // Division vs regex ambiguity
        let x = 10
        let y = 2
        let division = x / y // This is division

        // Extended regex literal
        let emailPattern = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/

        // More complex patterns
        let phonePattern = /\d{3}-\d{3}-\d{4}/
        let zipPattern = /\d{5}(-\d{4})?/
        let urlPattern = /https?:\/\/[\w\-.]+(:\d+)?(\/[\w\-./?%&=]*)?/

        // Named captures
        let namedCapture = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/

        // Using patterns
        let email = "test@example.com"
        if email.contains(emailPattern) {
            print("Valid email")
        }

        let phone = "555-123-4567"
        if let match = phone.firstMatch(of: phonePattern) {
            print(match.output)
        }

        let date = "2024-01-15"
        if let match = date.firstMatch(of: namedCapture) {
            print(match.year, match.month, match.day)
        }

        _ = (division, zipPattern, urlPattern)
    }

    // Regex builder patterns
    public func regexBuilder() {
        // Using RegexBuilder
        let digitPattern = /\d+/
        let wordPattern = /\w+/
        let whitespacePattern = /\s+/

        let text = "Hello 123 World 456"
        let digits = text.matches(of: digitPattern)
        let words = text.matches(of: wordPattern)

        print(digits.count, words.count)
        _ = whitespacePattern
    }

    // Potential regex issues
    public func potentialIssues() {
        // Empty pattern
        let empty = //

        // Very simple patterns that could be string methods
        let simple1 = /a/
        let simple2 = /test/
        let simple3 = /./

        // Patterns with potential escaping issues
        let specialChars = /\[\]\(\)\{\}/
        let backslashes = /\\/

        let text = "test [value]"
        _ = text.contains(simple1)
        _ = text.contains(simple2)
        _ = text.contains(simple3)
        _ = text.contains(specialChars)
        _ = (empty, backslashes)
    }

    // NSRegularExpression patterns (older API)
    public func nsRegexPatterns() throws {
        // Using NSRegularExpression
        let pattern1 = try NSRegularExpression(pattern: "[0-9]+")
        let pattern2 = try NSRegularExpression(pattern: "\\w+", options: .caseInsensitive)
        let pattern3 = try NSRegularExpression(pattern: "^test.*$", options: [.anchorsMatchLines])

        let text = "test 123 TEST"
        let range = NSRange(text.startIndex..., in: text)

        let matches1 = pattern1.matches(in: text, range: range)
        let matches2 = pattern2.matches(in: text, range: range)
        let matches3 = pattern3.matches(in: text, range: range)

        print(matches1.count, matches2.count, matches3.count)
    }

    // String-based pattern matching
    public func stringPatterns() {
        let text = "Hello, World!"

        // These could potentially use regex
        _ = text.range(of: "Hello")
        _ = text.range(of: "World")
        _ = text.range(of: "[A-Z]", options: .regularExpression)

        // Replacing with patterns
        let replaced = text.replacingOccurrences(
            of: "[aeiou]",
            with: "*",
            options: .regularExpression
        )
        print(replaced)
    }
}

// Regex in different contexts
public func regexInDifferentContexts() {
    // In guard statements
    let input = "user@domain.com"
    guard input.contains(/\w+@\w+\.\w+/) else {
        return
    }

    // In switch expressions
    let code = "ABC123"
    switch code {
    case /[A-Z]{3}\d{3}/:
        print("Valid code format")
    default:
        print("Invalid")
    }

    // In if let
    if let match = "2024-01-15".firstMatch(of: /(\d{4})-(\d{2})-(\d{2})/) {
        print(match.output)
    }

    // In collection operations
    let emails = ["a@b.com", "invalid", "c@d.org"]
    let valid = emails.filter { $0.contains(/\w+@\w+\.\w+/) }
    print(valid)
}

// Regex compilation issues
public func regexCompilation() {
    // Patterns that might fail at runtime
    do {
        let complexPattern = try Regex("[a-z]+(?=\\d)")
        let text = "abc123"
        if let match = text.firstMatch(of: complexPattern) {
            print(match.output)
        }
    } catch {
        print("Regex error: \(error)")
    }

    // Dynamic regex construction
    let userInput = "[a-z]+"
    do {
        let dynamicRegex = try Regex(userInput)
        _ = "test".contains(dynamicRegex)
    } catch {
        print("Invalid regex: \(error)")
    }
}

// Regex with semantic versioning example
public func versionParsing() {
    let semverPattern = /(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)(-(?<prerelease>[\w.]+))?(\+(?<build>[\w.]+))?/

    let versions = ["1.0.0", "2.3.4-beta.1", "3.0.0+build.123", "1.2.3-alpha+001"]

    for version in versions {
        if let match = version.firstMatch(of: semverPattern) {
            print("Major: \(match.major), Minor: \(match.minor), Patch: \(match.patch)")
        }
    }
}
