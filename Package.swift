// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.18.5"
let checksum = "237a2d58948050061da82e7a130600edc0d4a608abc77bc08c7b5c6508925010" // Updated by CI on release

let package = Package(
    name: "VauchiPlatform",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "VauchiPlatform",
            targets: ["VauchiPlatform", "VauchiPlatformFFI"]
        ),
    ],
    targets: [
        // Swift bindings that wrap the FFI layer
        .target(
            name: "VauchiPlatform",
            dependencies: ["VauchiPlatformFFI"],
            path: "Sources/VauchiPlatform"
        ),
        // Binary XCFramework containing the native Rust library
        // REMOTE (original, restored by wire-bindings-remote.sh):
        // .binaryTarget(
        //     name: "VauchiPlatformFFI",
        //     url: "...",
        //     checksum: checksum
        // ),
        // LOCAL (set by wire-bindings-local.sh):
        .binaryTarget(
            name: "VauchiPlatformFFI",
            path: "VauchiPlatformFFI.xcframework"
        ),
    ]
)
