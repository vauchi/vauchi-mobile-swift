// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.17"
let checksum = "91698c47255ac55973bb27e0ce061dd9a670787a381bd4638a978695d2b7f0bd" // Updated by CI on release

let package = Package(
    name: "VauchiMobile",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
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
