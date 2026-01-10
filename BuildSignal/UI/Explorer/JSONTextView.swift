import AppKit
import SwiftUI

/// A SwiftUI wrapper around NSTextView for efficiently displaying large JSON content.
/// NSTextView handles large text much better than SwiftUI's Text or TextEditor.
struct JSONTextView: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        // Configure text view
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor = NSColor.textColor
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.autoresizingMask = [.width]
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false

        // Allow horizontal scrolling
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.containerSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.isHorizontallyResizable = true

        // Set the text
        textView.string = text

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        // Only update if text changed
        if textView.string != text {
            textView.string = text
        }
    }
}

#Preview {
    JSONTextView(text: """
    {
        "title": "Build MyApp",
        "duration": 45.5,
        "warnings": [
            {"message": "Unused variable 'x'", "file": "main.swift", "line": 42}
        ]
    }
    """)
    .frame(width: 500, height: 400)
}
