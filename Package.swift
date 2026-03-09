// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.6.2"
let checksum = "889fdafb2beaeaddc3da01d1926da2ab657c79277b1faa06f29d9f3a31548b0b" // Updated by CI on release

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
