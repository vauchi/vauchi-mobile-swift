// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.18.4"
let checksum = "2f01e1f5e56b3053eb10b8ead87b060dd04b87353d744684d8f524a0455ad85c" // Updated by CI on release

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
