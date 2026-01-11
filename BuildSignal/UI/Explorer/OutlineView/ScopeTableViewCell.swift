import AppKit

/// Table cell for displaying a directory node in the scope sidebar outline view.
/// Shows folder/file icon, name, and warning count badge.
final class ScopeTableViewCell: NSTableCellView {

    private let iconView: NSImageView
    private let nameLabel: NSTextField
    private let badgeLabel: NSTextField

    init(frame frameRect: NSRect, node: DirectoryNode) {
        iconView = NSImageView()
        nameLabel = NSTextField(labelWithString: "")
        badgeLabel = NSTextField(labelWithString: "")

        super.init(frame: frameRect)

        setupViews()
        configure(with: node)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Icon
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.symbolConfiguration = .init(pointSize: 13, weight: .regular)
        addSubview(iconView)

        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.isEditable = false
        nameLabel.isBordered = false
        nameLabel.drawsBackground = false
        nameLabel.font = .systemFont(ofSize: 13)
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(nameLabel)

        // Badge
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.isEditable = false
        badgeLabel.isBordered = false
        badgeLabel.drawsBackground = false
        badgeLabel.font = .systemFont(ofSize: 10, weight: .medium)
        badgeLabel.textColor = .secondaryLabelColor
        badgeLabel.alignment = .center
        badgeLabel.wantsLayer = true
        badgeLabel.layer?.cornerRadius = 3
        badgeLabel.layer?.backgroundColor = NSColor.secondaryLabelColor.withAlphaComponent(0.15).cgColor
        badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(badgeLabel)

        // Layout
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: badgeLabel.leadingAnchor, constant: -8),

            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            badgeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            badgeLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    private func configure(with node: DirectoryNode) {
        // Icon - use SF Symbols like CodeEdit
        let (iconName, iconColor) = Self.iconInfo(for: node)
        iconView.image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
        iconView.contentTintColor = iconColor

        // Name
        nameLabel.stringValue = node.name

        // Badge - show warning count
        if node.warningCount > 0 {
            badgeLabel.stringValue = "\(node.warningCount)"
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }

    // MARK: - File Icon Mapping (CodeEdit style)

    private static func iconInfo(for node: DirectoryNode) -> (name: String, color: NSColor) {
        // Folders use folder.fill with blue
        if !node.isLeaf {
            return ("folder.fill", .systemBlue)
        }

        // Get file extension
        let ext = (node.name as NSString).pathExtension.lowercased()

        switch ext {
        // Swift
        case "swift":
            return ("swift", .systemOrange)

        // Objective-C
        case "h":
            return ("h.square", NSColor(red: 0.667, green: 0.031, blue: 0.133, alpha: 1.0))
        case "m":
            return ("m.square", NSColor(red: 0.271, green: 0.106, blue: 0.525, alpha: 1.0))

        // C/C++
        case "c", "cpp", "cc":
            return ("c.square", .systemPurple)

        // Web
        case "js", "mjs":
            return ("doc.text", NSColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0)) // Amber
        case "ts":
            return ("doc.text", .systemBlue)
        case "jsx", "tsx":
            return ("atom", .systemCyan)
        case "html", "htm":
            return ("chevron.left.forwardslash.chevron.right", .systemOrange)
        case "css", "scss", "sass":
            return ("curlybraces", .systemTeal)

        // Data
        case "json":
            return ("curlybraces", NSColor(red: 0.95, green: 0.3, blue: 0.2, alpha: 1.0)) // Scarlet
        case "yml", "yaml":
            return ("doc.text", NSColor(red: 0.95, green: 0.3, blue: 0.2, alpha: 1.0))
        case "xml":
            return ("chevron.left.forwardslash.chevron.right", .systemOrange)
        case "plist":
            return ("tablecells", .systemGray)

        // Config
        case "xcconfig":
            return ("gearshape.2", .systemGray)
        case "entitlements":
            return ("checkmark.seal", NSColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0))

        // Documentation
        case "md", "markdown":
            return ("doc.plaintext", .systemGray)
        case "txt":
            return ("doc.plaintext", .systemGray)
        case "rtf":
            return ("doc.richtext", .systemGray)

        // Scripts
        case "sh", "bash", "zsh":
            return ("terminal", .systemGray)
        case "py":
            return ("doc.text", NSColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0))
        case "rb":
            return ("doc.text", NSColor(red: 0.95, green: 0.3, blue: 0.2, alpha: 1.0))

        // Other languages
        case "go":
            return ("g.square", NSColor(red: 0.02, green: 0.675, blue: 0.757, alpha: 1.0))
        case "rs":
            return ("r.square", .systemOrange)
        case "java":
            return ("cup.and.saucer", .systemBlue)
        case "kt", "kts":
            return ("k.square", .systemPurple)

        // Images
        case "png", "jpg", "jpeg", "gif", "webp", "ico", "svg":
            return ("photo", .systemBlue)
        case "pdf":
            return ("doc.richtext", .systemRed)

        // Strings/Localization
        case "strings", "stringsdict":
            return ("text.quote", NSColor(red: 0.95, green: 0.3, blue: 0.2, alpha: 1.0))

        // Default
        default:
            return ("doc", .systemGray)
        }
    }
}
