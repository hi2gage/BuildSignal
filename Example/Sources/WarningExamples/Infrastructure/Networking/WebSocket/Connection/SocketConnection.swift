// MARK: - SocketConnection - Async/Await Warnings

import Foundation

public class SocketConnection {
    public init() {}

    // MARK: - Async in Sync Context
    public func syncMethod() {
        // Creating tasks but not awaiting
        Task {
            await asyncOperation1()
        }

        Task {
            await asyncOperation2()
        }

        // Detached tasks
        Task.detached {
            await self.asyncOperation3()
        }
    }

    private func asyncOperation1() async {
        print("op1")
    }

    private func asyncOperation2() async {
        print("op2")
    }

    private func asyncOperation3() async {
        print("op3")
    }

    // MARK: - Unnecessary Async
    public func unnecessaryAsync() async {
        // No async operations in async function
        let x = 1 + 1
        let y = "hello" + " world"
        print(x, y)
    }

    // MARK: - Await in Loop Without Concurrency
    public func sequentialAwaits() async {
        // Sequential awaits that could be concurrent
        let result1 = await asyncOperation1()
        let result2 = await asyncOperation2()
        let result3 = await asyncOperation3()

        print(result1, result2, result3)
    }

    // MARK: - MainActor Isolation Warnings
    @MainActor
    public func mainActorMethod() {
        print("on main actor")
    }

    public func callMainActor() async {
        // Crossing to main actor
        await mainActorMethod()
        await mainActorMethod()
        await mainActorMethod()
    }

    // MARK: - Sendable Closure Issues
    public func sendableIssues() {
        var mutableState = 0

        // Capturing mutable state in Sendable closure
        Task {
            mutableState += 1
            print(mutableState)
        }

        Task {
            mutableState += 2
        }

        Task.detached {
            print(mutableState)
        }
    }

    // MARK: - Actor Reentrancy
    public actor ConnectionActor {
        var state = 0

        func modify() async {
            state += 1
            // Reentrancy point
            await Task.yield()
            state += 1
        }
    }

    // MARK: - Redundant Task
    public func redundantTask() async {
        // Task inside async context
        await Task {
            print("inside task")
        }.value
    }
}
