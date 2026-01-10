// MARK: - ChatView - Escaping Closure & Capture Warnings

import Foundation

public class ChatView {
    public var messages: [String] = []
    private var observers: [() -> Void] = []

    public init() {}

    // MARK: - Escaping Closure Captures
    public func setupObservers() {
        // Capturing self in escaping closure without explicit capture
        observers.append {
            self.messages.append("new message") // implicit self capture
        }

        observers.append {
            print(self.messages.count) // implicit self
        }

        observers.append {
            self.handleMessage() // implicit self
        }
    }

    // MARK: - Capture List Warnings
    public func captureListIssues() {
        var mutableValue = 10
        var anotherMutable = 20

        // Capturing mutable variable
        let closure1 = {
            print(mutableValue)
        }

        // Capturing multiple mutables
        let closure2 = {
            print(mutableValue, anotherMutable)
        }

        // Modifying captured value
        let closure3 = {
            mutableValue += 1
            anotherMutable += 1
        }

        closure1()
        closure2()
        closure3()
    }

    // MARK: - Unused Capture List Items
    public func unusedCaptures() {
        let value1 = 10
        let value2 = 20
        let value3 = 30

        // Capturing values but not using them
        let closure1 = { [value1] in
            print("not using value1")
        }

        let closure2 = { [value1, value2] in
            print("not using captures")
        }

        let closure3 = { [value1, value2, value3] in
            print("capturing all, using none")
        }

        closure1()
        closure2()
        closure3()
    }

    private func handleMessage() {
        print("handling")
    }

    // MARK: - Redundant Return in Single Expression
    public func singleExpressionReturns() -> Int {
        return 42 // Could be just: 42
    }

    public func anotherRedundantReturn() -> String {
        return "hello" // Could be just: "hello"
    }

    public var computedProperty: Int {
        return messages.count // redundant return
    }
}
