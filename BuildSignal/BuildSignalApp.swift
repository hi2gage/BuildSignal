//
//  BuildSignalApp.swift
//  BuildSignal
//
//  Created by Gage Halverson on 1/9/26.
//

import SwiftUI
import WelcomeWindow

@main
struct BuildSignalApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var recentProjectsManager = RecentProjectsManager.shared
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        // Welcome Window - shows on launch
        WelcomeWindow(
            title: "BuildSignal",
            actions: { dismiss in
                WelcomeButton(
                    iconName: "folder.badge.gearshape",
                    title: "Browse DerivedData",
                    action: {
                        openWindow(id: "derived-data-browser")
                    }
                )
                WelcomeButton(
                    iconName: "folder",
                    title: "Open Folder...",
                    action: {
                        openFolderDialog(dismiss: dismiss)
                    }
                )
            },
            customRecentsList: { dismiss in
                RecentProjectsListView(
                    recentProjects: recentProjectsManager.recentProjects,
                    onSelect: { project in
                        openRecentProject(project, dismiss: dismiss)
                    },
                    onRemove: { project in
                        recentProjectsManager.removeRecentProject(project)
                    }
                )
            },
            onDrop: { url, dismiss in
                handleDroppedURL(url, dismiss: dismiss)
            }
        )

        // DerivedData Browser Window
        Window("Browse DerivedData", id: "derived-data-browser") {
            DerivedDataBrowserView(
                onSelectProject: { project in
                    appState.selectedProject = project
                    recentProjectsManager.addRecentProject(project)
                    openMainWindow()
                    closeBrowserAndWelcomeWindows()
                }
            )
        }
        .windowResizability(.contentSize)

        // Main Window - shows when project is selected
        WindowGroup(id: "main") {
            Group {
                if let project = appState.selectedProject {
                    MainProjectView(project: project)
                        .onAppear {
                            recentProjectsManager.addRecentProject(project)
                        }
                } else {
                    ContentUnavailableView(
                        "No Project Selected",
                        systemImage: "hammer",
                        description: Text("Close this window and select a project from the welcome screen")
                    )
                }
            }
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1000, height: 700)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                Button("Browse DerivedData...") {
                    openWindow(id: "derived-data-browser")
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])

                Divider()
            }
        }
    }

    // MARK: - Actions

    private func openFolderDialog(dismiss: @escaping () -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select a DerivedData project folder"
        panel.prompt = "Select"

        if panel.runModal() == .OK, let url = panel.url {
            handleDroppedURL(url, dismiss: dismiss)
        }
    }

    private func handleDroppedURL(_ url: URL, dismiss: @escaping () -> Void) {
        Task {
            let scanner = DerivedDataScanner()
            if let project = await scanner.parseProject(at: url) {
                appState.selectedProject = project
                dismiss()
                openMainWindow()
            }
        }
    }

    private func openRecentProject(_ recent: RecentProject, dismiss: @escaping () -> Void) {
        Task {
            let scanner = DerivedDataScanner()
            if let project = await scanner.parseProject(at: recent.derivedDataPath) {
                appState.selectedProject = project
                dismiss()
                openMainWindow()
            } else if let minimal = recent.toXcodeProject() {
                appState.selectedProject = minimal
                dismiss()
                openMainWindow()
            }
        }
    }

    private func openMainWindow() {
        openWindow(id: "main")
    }

    private func closeBrowserAndWelcomeWindows() {
        for window in NSApp.windows {
            let id = window.identifier?.rawValue ?? ""
            if id == "welcome" || id.contains("derived-data-browser") {
                window.close()
            }
        }
    }
}
