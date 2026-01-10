import Combine
import Foundation

/// ViewModel for the DerivedData browser that manages project loading.
@MainActor
final class DerivedDataBrowserViewModel: ObservableObject {
    @Published private(set) var projects: [XcodeProject] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private let scanner = DerivedDataScanner()

    func loadProjects() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            let loadedProjects = try await scanner.scanProjects()
            projects = loadedProjects
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadProjects()
    }
}
