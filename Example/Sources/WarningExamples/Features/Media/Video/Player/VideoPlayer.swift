// MARK: - VideoPlayer - Memory & Reference Warnings

import Foundation

// MARK: - Potential Reference Cycle
public class VideoPlayer {
    public var onComplete: (() -> Void)?
    public var onError: ((Error) -> Void)?
    public var onProgress: ((Double) -> Void)?

    public var delegate: VideoPlayerDelegate?

    public init() {}

    // MARK: - Self Capture in Stored Closure
    public func setupCallbacks() {
        // Potential retain cycle - self captured in stored closure
        onComplete = {
            self.handleCompletion()
        }

        onError = { error in
            self.handleError(error)
        }

        onProgress = { progress in
            self.updateProgress(progress)
        }
    }

    private func handleCompletion() {
        print("completed")
    }

    private func handleError(_ error: Error) {
        print("error: \(error)")
    }

    private func updateProgress(_ progress: Double) {
        print("progress: \(progress)")
    }

    // MARK: - Redundant Protocol Declaration
    public func playVideo() {
        // Unused local protocol
        protocol LocalProtocol {
            func doSomething()
        }

        print("playing")
    }

    // MARK: - Empty Protocol
    public func configurePlayer() {
        print("configuring")
    }

    // MARK: - Duplicate Code in Branches
    public func seekTo(position: Double) {
        if position < 0 {
            print("seeking")
            updateProgress(0)
        } else if position > 100 {
            print("seeking")
            updateProgress(100)
        } else {
            print("seeking")
            updateProgress(position)
        }
    }

    // MARK: - Yoda Conditions
    public func checkState() {
        let state = "playing"

        // Yoda condition style
        if "playing" == state {
            print("is playing")
        }

        if "paused" == state {
            print("is paused")
        }

        let count = 5
        if 0 == count {
            print("zero")
        }
    }

    // MARK: - Nested Function Shadows
    public func process() {
        func helper() {
            print("outer helper")
        }

        func inner() {
            func helper() { // shadows outer helper
                print("inner helper")
            }
            helper()
        }

        helper()
        inner()
    }
}

// Empty protocol - potential warning
public protocol VideoPlayerDelegate {
}
