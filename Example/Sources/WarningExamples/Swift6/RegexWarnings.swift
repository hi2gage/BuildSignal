// MARK: - Regex Warnings - Swift 5.7+

import Foundation

// Regex patterns using NSRegularExpression and string-based patterns
public class RegexWarnings {
    public init() {}

    // Division vs regex - showing the pattern
    public func divisionPattern() {
        let x = 10
        let y = 2
        let division = x / y // This is division, not regex
        print(division)
    }

    // NSRegularExpression patterns (most compatible)
    public func nsRegexPatterns() throws {
        // Using NSRegularExpression
        let pattern1 = try NSRegularExpression(pattern: "[0-9]+")
        let pattern2 = try NSRegularExpression(pattern: "\\w+", options: .caseInsensitive)
        let pattern3 = try NSRegularExpression(pattern: "^test.*$", options: [.anchorsMatchLines])
        let pattern4 = try NSRegularExpression(pattern: "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        let pattern5 = try NSRegularExpression(pattern: "\\d{3}-\\d{3}-\\d{4}")

        let text = "test 123 TEST email@example.com 555-123-4567"
        let range = NSRange(text.startIndex..., in: text)

        let matches1 = pattern1.matches(in: text, range: range)
        let matches2 = pattern2.matches(in: text, range: range)
        let matches3 = pattern3.matches(in: text, range: range)
        let matches4 = pattern4.matches(in: text, range: range)
        let matches5 = pattern5.matches(in: text, range: range)

        print(matches1.count, matches2.count, matches3.count, matches4.count, matches5.count)
    }

    // String-based pattern matching
    public func stringPatterns() {
        let text = "Hello, World! 12345"

        // These could potentially use regex
        let _ = text.range(of: "Hello")
        let _ = text.range(of: "World")
        let _ = text.range(of: "[A-Z]", options: .regularExpression)
        let _ = text.range(of: "[0-9]+", options: .regularExpression)
        let _ = text.range(of: "\\w+", options: .regularExpression)

        // Replacing with patterns
        let replaced1 = text.replacingOccurrences(
            of: "[aeiou]",
            with: "*",
            options: .regularExpression
        )

        let replaced2 = text.replacingOccurrences(
            of: "[0-9]",
            with: "#",
            options: .regularExpression
        )

        print(replaced1, replaced2)
    }

    // Regex using Swift's Regex type with string
    public func swiftRegexWithString() throws {
        // Using Regex with string pattern
        let digitPattern = try Regex("[0-9]+")
        let wordPattern = try Regex("[a-zA-Z]+")
        let emailPattern = try Regex("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")

        let text = "Hello 123 World test@example.com"

        if let digitMatch = text.firstMatch(of: digitPattern) {
            print("Digits: \(digitMatch.output)")
        }

        if let wordMatch = text.firstMatch(of: wordPattern) {
            print("Word: \(wordMatch.output)")
        }

        if let emailMatch = text.firstMatch(of: emailPattern) {
            print("Email: \(emailMatch.output)")
        }
    }

    // Multiple regex patterns
    public func multiplePatterns() throws {
        let patterns = [
            try NSRegularExpression(pattern: "\\d+"),
            try NSRegularExpression(pattern: "[A-Z]+"),
            try NSRegularExpression(pattern: "\\s+"),
            try NSRegularExpression(pattern: "[a-z]+"),
            try NSRegularExpression(pattern: "[^\\w]+")
        ]

        let text = "Hello World 123"
        let range = NSRange(text.startIndex..., in: text)

        for pattern in patterns {
            let matches = pattern.matches(in: text, range: range)
            print("Pattern found \(matches.count) matches")
        }
    }

    // Regex validation patterns
    public func validationPatterns() throws {
        // Email validation
        let emailPattern = try NSRegularExpression(
            pattern: "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        )

        // Phone validation
        let phonePattern = try NSRegularExpression(
            pattern: "^\\d{3}-\\d{3}-\\d{4}$"
        )

        // Zip code validation
        let zipPattern = try NSRegularExpression(
            pattern: "^\\d{5}(-\\d{4})?$"
        )

        // URL validation
        let urlPattern = try NSRegularExpression(
            pattern: "^https?://[\\w\\-.]+(:\\d+)?(/[\\w\\-./?%&=]*)?$"
        )

        // Test strings
        let email = "test@example.com"
        let phone = "555-123-4567"
        let zip = "12345-6789"
        let url = "https://example.com/path"

        func validate(_ text: String, with pattern: NSRegularExpression) -> Bool {
            let range = NSRange(text.startIndex..., in: text)
            return pattern.firstMatch(in: text, range: range) != nil
        }

        print(validate(email, with: emailPattern))
        print(validate(phone, with: phonePattern))
        print(validate(zip, with: zipPattern))
        print(validate(url, with: urlPattern))
    }

    // Regex capture groups
    public func captureGroups() throws {
        // Date pattern with groups
        let datePattern = try NSRegularExpression(
            pattern: "(\\d{4})-(\\d{2})-(\\d{2})"
        )

        let dateString = "2024-01-15"
        let range = NSRange(dateString.startIndex..., in: dateString)

        if let match = datePattern.firstMatch(in: dateString, range: range) {
            let year = String(dateString[Range(match.range(at: 1), in: dateString)!])
            let month = String(dateString[Range(match.range(at: 2), in: dateString)!])
            let day = String(dateString[Range(match.range(at: 3), in: dateString)!])
            print("Year: \(year), Month: \(month), Day: \(day)")
        }
    }

    // Regex replacement with captures
    public func replacementWithCaptures() throws {
        let pattern = try NSRegularExpression(pattern: "(\\w+)@(\\w+)\\.(\\w+)")

        let email = "user@domain.com"
        let range = NSRange(email.startIndex..., in: email)

        // Replace with captured groups
        let masked = pattern.stringByReplacingMatches(
            in: email,
            range: range,
            withTemplate: "***@$2.$3"
        )

        print(masked)
    }
}

// Regex in different contexts
public func regexInDifferentContexts() throws {
    // In guard statements
    let input = "user@domain.com"
    let emailRegex = try Regex("[\\w]+@[\\w]+\\.[\\w]+")

    guard input.contains(emailRegex) else {
        return
    }

    print("Valid email format")

    // In collection operations
    let emails = ["a@b.com", "invalid", "c@d.org"]
    let valid = try emails.filter { email in
        email.contains(try Regex("[\\w]+@[\\w]+\\.[\\w]+"))
    }
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

// Version parsing with regex
public func versionParsing() throws {
    let semverPattern = try NSRegularExpression(
        pattern: "(\\d+)\\.(\\d+)\\.(\\d+)(-([\\w.]+))?(\\+([\\w.]+))?"
    )

    let versions = ["1.0.0", "2.3.4-beta.1", "3.0.0+build.123", "1.2.3-alpha+001"]

    for version in versions {
        let range = NSRange(version.startIndex..., in: version)
        if let match = semverPattern.firstMatch(in: version, range: range) {
            let major = String(version[Range(match.range(at: 1), in: version)!])
            let minor = String(version[Range(match.range(at: 2), in: version)!])
            let patch = String(version[Range(match.range(at: 3), in: version)!])
            print("Major: \(major), Minor: \(minor), Patch: \(patch)")
        }
    }
}
