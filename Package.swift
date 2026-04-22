// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.21.6"
let checksum = "0aec0403d2b48b563d24062cb20b2cb5a874e82173d0417170d291c58926671a" // Updated by CI on release

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
        // Pure-Swift data types for core-driven screens (ScreenModel,
        // Component, UserAction, ActionResult, DesignTokens, component
        // payloads). Depended on by iOS and macOS so the two frontends
        // share one canonical deserialization surface instead of
        // maintaining parallel `Vauchi/CoreUI/Models.swift` copies.
        // Problem: 2026-04-22-shared-coreui-models-package.
        .library(
            name: "CoreUIModels",
            targets: ["CoreUIModels"]
        ),
    ],
    targets: [
        // Swift bindings that wrap the FFI layer
        .target(
            name: "VauchiPlatform",
            dependencies: ["VauchiPlatformFFI"],
            path: "Sources/VauchiPlatform"
        ),
        // Shared core-UI data types (POD + Decodable). No dependency on
        // VauchiPlatformFFI — pure Swift, built from source on every
        // consumer build. Safe to reference from any Swift module.
        .target(
            name: "CoreUIModels",
            path: "Sources/CoreUIModels"
        ),
        .binaryTarget(
            name: "VauchiPlatformFFI",
            url: "https://gitlab.com/api/v4/projects/vauchi%2Fcore/packages/generic/vauchi-platform/\(version)/VauchiPlatformFFI.xcframework.zip",
            checksum: checksum
        ),
    ]
)
