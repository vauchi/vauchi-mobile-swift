// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.18.6"
let checksum = "db9f803142d7616bb0cb84a337c4d855c402a08569345d29550ab8ad98d7edb1" // Updated by CI on release

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
