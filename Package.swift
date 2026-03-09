// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.5.0-rc.0"
let checksum = "572446320e8a1d032e4755e2bf0e59638d69e1611d0808496c402b646e037036" // Updated by CI on release

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
        // REMOTE (original, restored by wire-bindings-remote.sh):
        // .binaryTarget(
        //     name: "VauchiMobileFFI",
        //     url: "...",
        //     checksum: checksum
        // ),
        // LOCAL (set by wire-bindings-local.sh):
        .binaryTarget(
            name: "VauchiMobileFFI",
            path: "VauchiMobileFFI.xcframework"
        ),
    ]
)
