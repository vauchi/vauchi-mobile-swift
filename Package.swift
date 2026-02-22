// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.16"
let checksum = "9f3807a4eee50133fae6907118c2a29389965c61f839d6041fc26dfec7a45295" // Updated by CI on release

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
