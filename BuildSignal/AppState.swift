import Combine
import Foundation

/// Shared application state for managing the selected project.
@MainActor
final class AppState: ObservableObject {
    @Published var selectedProject: XcodeProject?
}
