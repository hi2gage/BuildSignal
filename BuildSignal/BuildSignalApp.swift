//
//  BuildSignalApp.swift
//  BuildSignal
//
//  Created by Gage Halverson on 1/9/26.
//

import SwiftUI

@main
struct BuildSignalApp: App {
    var body: some Scene {
        WindowGroup {
            ProjectSelectionView()
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 600)
        .commands {
            SidebarCommands()
        }
    }
}
