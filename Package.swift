// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let version = "0.24.1"
let checksum = "af860cfae1d54752869adc5eff6bba11799c7f81761c80fbf9c75ffdf39c26e1" // Updated by CI on release

// Binary-target source: defaults to the published URL artifact (verified
// by `checksum` above). When VAUCHI_PLATFORM_USE_LOCAL_XCFRAMEWORK is set
// in the consumer's environment at SPM resolve time, the manifest emits a
// `path:` target instead — letting CI and `wire-bindings-local.sh`
// pre-place a `VauchiPlatformFFI.xcframework/` next to this Package.swift
// without going through SwiftPM's URLSession download path. Why: SwiftPM's
// URLSession `timeoutIntervalForResource` defaults to 7 days with no
// override, and Cloudflare-fronted GitLab generic-package URLs hang
// silently for the full timeout in CI runners — see
// _private/docs/problems/2026-04-26-vauchi-platform-swift-resolve-hang/.
let useLocalXCFramework = ProcessInfo.processInfo.environment[
    "VAUCHI_PLATFORM_USE_LOCAL_XCFRAMEWORK"
] != nil

let binaryTarget: PackageDescription.Target = useLocalXCFramework
    ? .binaryTarget(
     name: "VauchiPlatformFFI",
     url: "https://gitlab.com/api/v4/projects/vauchi%2Fcore/packages/generic/vauchi-platform/\(version)/VauchiPlatformFFI.xcframework.zip",
     checksum: checksum
 ),
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
        binaryTarget,
    ]
)
