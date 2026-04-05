// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.18.2"
let checksum = "372fc363818071bedfc60c841a22d990085c0cee8e550ead1c8626507767f5aa" // Updated by CI on release

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
