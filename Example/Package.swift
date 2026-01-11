// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WarningExamples",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "WarningExamples",
            targets: ["WarningExamples"]
        ),
    ],
    targets: [
        .target(
            name: "WarningExamples",
            swiftSettings: [
                // Enable strict concurrency checking to generate concurrency warnings
                .enableExperimentalFeature("StrictConcurrency"),
                // Enable upcoming features that generate warnings
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("DeprecateApplicationMain"),
                .enableUpcomingFeature("DisableOutwardActorInference"),
                .enableUpcomingFeature("GlobalConcurrency"),
                .enableUpcomingFeature("ImportObjcForwardDeclarations"),
                .enableUpcomingFeature("IsolatedDefaultValues"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("InferSendableFromCaptures"),
            ]
        ),
    ]
)
