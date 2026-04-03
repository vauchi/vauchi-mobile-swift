// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.14.0"
let checksum = "4b96cc8f0c5fc394ec6bb250a9e6bb9689ee9af4f202f98812d93f7e1b4d9c42" // Updated by CI on release

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
        .binaryTarget(
            name: "VauchiPlatformFFI",
            url: "https://gitlab.com/api/v4/projects/vauchi%2Fcore/packages/generic/vauchi-platform/\(version)/VauchiPlatformFFI.xcframework.zip",
            checksum: checksum
        ),
    ]
)
