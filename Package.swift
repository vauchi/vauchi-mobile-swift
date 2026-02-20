// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.14"
let checksum = "ceed24790e6302a2a01e770f57c41a09c670dcc0aecb364e4b79de41a1e8c174"  // Updated by CI on release

let package = Package(
    name: "VauchiMobile",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "VauchiMobile",
            targets: ["VauchiMobile", "VauchiMobileFFI"]
        ),
    ],
    targets: [
        // Swift bindings that wrap the FFI layer
        .target(
            name: "VauchiMobile",
            dependencies: ["VauchiMobileFFI"],
            path: "Sources/VauchiMobile"
        ),
        // Binary XCFramework containing the native Rust library
        .binaryTarget(
            name: "VauchiMobileFFI",
            url: "https://gitlab.com/api/v4/projects/vauchi%2Fcore/packages/generic/vauchi-mobile/\(version)/VauchiMobileFFI.xcframework.zip",
            checksum: checksum
        ),
    ]
)
