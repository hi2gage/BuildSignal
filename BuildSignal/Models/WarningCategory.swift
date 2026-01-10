import SwiftUI
import XCLogParser

/// A category for grouping warnings by pattern matching.
/// Can be used for both built-in "smart" categories and user-defined custom categories.
struct WarningCategory: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var icon: String
    var colorName: String  // Store color as a name for Codable
    var patterns: [String]  // Regex patterns to match against warning title
    var sortOrder: Int
    let isBuiltIn: Bool

    /// SwiftUI Color computed from colorName
    var color: Color {
        Self.colorFromName(colorName)
    }

    init(
        id: String,
        name: String,
        icon: String,
        color: Color,
        patterns: [String],
        sortOrder: Int,
        isBuiltIn: Bool = true
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorName = Self.nameFromColor(color)
        self.patterns = patterns
        self.sortOrder = sortOrder
        self.isBuiltIn = isBuiltIn
    }

    init(
        id: String,
        name: String,
        icon: String,
        colorName: String,
        patterns: [String],
        sortOrder: Int,
        isBuiltIn: Bool = true
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorName = colorName
        self.patterns = patterns
        self.sortOrder = sortOrder
        self.isBuiltIn = isBuiltIn
    }

    /// Check if a warning matches this category's patterns
    func matches(_ warning: Notice) -> Bool {
        guard !patterns.isEmpty else { return false }

        let title = warning.title.lowercased()

        // Special case for deprecations - also check the notice type
        if id == "deprecations" && warning.type == .deprecatedWarning {
            return true
        }

        return patterns.contains { pattern in
            // Try regex first, fall back to simple contains
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(title.startIndex..., in: title)
                return regex.firstMatch(in: title, range: range) != nil
            } else {
                return title.contains(pattern.lowercased())
            }
        }
    }

    // For Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: WarningCategory, rhs: WarningCategory) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Color Helpers

    /// Available colors for categories
    static let availableColors: [(name: String, color: Color)] = [
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("mint", .mint),
        ("teal", .teal),
        ("cyan", .cyan),
        ("blue", .blue),
        ("indigo", .indigo),
        ("purple", .purple),
        ("pink", .pink),
        ("gray", .gray),
        ("brown", .brown)
    ]

    static func colorFromName(_ name: String) -> Color {
        availableColors.first { $0.name == name }?.color ?? .yellow
    }

    static func nameFromColor(_ color: Color) -> String {
        // Try to match the color - this is approximate since Color comparison is tricky
        switch color {
        case .red: return "red"
        case .orange: return "orange"
        case .yellow: return "yellow"
        case .green: return "green"
        case .mint: return "mint"
        case .teal: return "teal"
        case .cyan: return "cyan"
        case .blue: return "blue"
        case .indigo: return "indigo"
        case .purple: return "purple"
        case .pink: return "pink"
        case .gray: return "gray"
        case .brown: return "brown"
        default: return "yellow"
        }
    }

    /// Available SF Symbols for categories
    static let availableIcons: [String] = [
        "exclamationmark.triangle",
        "exclamationmark.circle",
        "xmark.circle",
        "checkmark.circle",
        "questionmark.circle",
        "info.circle",
        "star",
        "flag",
        "tag",
        "folder",
        "doc",
        "trash",
        "clock",
        "clock.arrow.circlepath",
        "arrow.triangle.2.circlepath",
        "arrow.left.arrow.right",
        "bolt",
        "ant",
        "ladybug",
        "leaf",
        "flame",
        "drop",
        "snowflake",
        "cloud",
        "sun.max",
        "moon",
        "sparkles",
        "wand.and.stars",
        "textformat",
        "number",
        "a.circle",
        "6.circle.fill",
        "hammer",
        "wrench",
        "gearshape",
        "cpu",
        "memorychip",
        "network",
        "lock",
        "key"
    ]
}

// MARK: - Built-in Categories

extension WarningCategory {
    /// The "Other" category for warnings that don't match any pattern
    static let other = WarningCategory(
        id: "other",
        name: "Other",
        icon: "exclamationmark.triangle",
        color: .yellow,
        patterns: [],
        sortOrder: 999
    )

    /// All built-in smart categories
    static let builtInCategories: [WarningCategory] = [
        WarningCategory(
            id: "swift6",
            name: "Swift 6 Language Mode",
            icon: "6.circle.fill",
            color: .orange,
            patterns: [
                "swift 6 language mode"
            ],
            sortOrder: 0
        ),
        WarningCategory(
            id: "concurrency",
            name: "Concurrency",
            icon: "arrow.triangle.2.circlepath",
            color: .pink,
            patterns: [
                "no 'async' operations occur within 'await'",
                "non-sendable",
                "actor-isolated",
                "main actor",
                "@mainactor",
                "sendable",
                "data race",
                "concurrent"
            ],
            sortOrder: 1
        ),
        WarningCategory(
            id: "deprecations",
            name: "Deprecations",
            icon: "clock.arrow.circlepath",
            color: .purple,
            patterns: [
                "deprecated",
                "will be removed"
            ],
            sortOrder: 2
        ),
        WarningCategory(
            id: "unused",
            name: "Unused Code",
            icon: "trash",
            color: .gray,
            patterns: [
                "unused",
                "never used",
                "never read",
                "never mutated",
                "change 'var' to 'let'",
                "change var to let",
                "immutable",
                "result of call.*unused"
            ],
            sortOrder: 3
        ),
        WarningCategory(
            id: "typeConversion",
            name: "Type Conversions",
            icon: "arrow.left.arrow.right",
            color: .blue,
            patterns: [
                "coercion",
                "cast",
                "conversion",
                "always succeeds",
                "conditional cast"
            ],
            sortOrder: 4
        ),
        WarningCategory(
            id: "naming",
            name: "Naming",
            icon: "textformat",
            color: .teal,
            patterns: [
                "should start with",
                "non-standard",
                "naming",
                "rename"
            ],
            sortOrder: 5
        )
    ]

    /// Categorize a warning using the provided categories
    static func categorize(_ warning: Notice, using categories: [WarningCategory] = builtInCategories) -> WarningCategory {
        for category in categories.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            if category.matches(warning) {
                return category
            }
        }
        return .other
    }
}

// MARK: - Export/Import

extension WarningCategory {
    /// Export categories to JSON data for sharing
    static func exportToJSON(_ categories: [WarningCategory]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(categories)
    }

    /// Import categories from JSON data
    static func importFromJSON(_ data: Data) throws -> [WarningCategory] {
        let decoder = JSONDecoder()
        var categories = try decoder.decode([WarningCategory].self, from: data)
        // Mark imported categories as non-built-in and assign new IDs
        categories = categories.map { category in
            WarningCategory(
                id: "custom_\(UUID().uuidString.prefix(8))",
                name: category.name,
                icon: category.icon,
                colorName: category.colorName,
                patterns: category.patterns,
                sortOrder: category.sortOrder,
                isBuiltIn: false
            )
        }
        return categories
    }
}
