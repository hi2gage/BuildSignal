import SwiftUI

/// A row displaying a single warning category with its icon, name, and pattern count.
struct CategoryRowView: View {
    let category: WarningCategory
    let isBuiltIn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(category.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(category.name)
                        .font(.headline)

                    if isBuiltIn {
                        Text("Built-in")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary)
                            .cornerRadius(4)
                    }
                }

                Text("\(category.patterns.count) pattern\(category.patterns.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
#Preview("Built-in Category") {
    CategoryRowView(
        category: WarningCategory(
            id: "concurrency",
            name: "Concurrency",
            icon: "arrow.triangle.2.circlepath",
            colorName: "pink",
            patterns: ["sendable", "actor-isolated", "main actor"],
            sortOrder: 1,
            isBuiltIn: true
        ),
        isBuiltIn: true
    )
    .padding()
}

#Preview("Custom Category") {
    CategoryRowView(
        category: WarningCategory(
            id: "custom_test",
            name: "My Custom Rules",
            icon: "star.fill",
            colorName: "purple",
            patterns: [".*custom.*"],
            sortOrder: 100,
            isBuiltIn: false
        ),
        isBuiltIn: false
    )
    .padding()
}

#Preview("No Patterns") {
    CategoryRowView(
        category: WarningCategory(
            id: "empty",
            name: "Empty Category",
            icon: "folder",
            colorName: "gray",
            patterns: [],
            sortOrder: 50,
            isBuiltIn: false
        ),
        isBuiltIn: false
    )
    .padding()
}
#endif
