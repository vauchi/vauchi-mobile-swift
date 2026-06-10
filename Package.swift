// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let version = "0.51.52"
let checksum = "6771e6de8599adf53d0a440278cd5c22dd8ffd9903bbdbad4198ae5a0ef82ec6" // Updated by CI on release

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
        path: "VauchiPlatformFFI.xcframework"
    )
    : .binaryTarget(
        name: "VauchiPlatformFFI",
        url: "https://gitlab.com/api/v4/projects/vauchi%2Fcore/packages/generic/vauchi-platform/\(version)/VauchiPlatformFFI.xcframework.zip",
        checksum: checksum
    )

/// `CoreUIModels` is pure Swift; the rest of the package (VauchiPlatform +
/// the `VauchiPlatformFFI` xcframework) is Apple-only, so `swift test` can't
/// build it on a Linux CI runner. When VAUCHI_COREUIMODELS_TEST_ONLY is set
/// (the `test:coreuimodels` CI job only), the manifest emits just
/// `CoreUIModels` + its test target, letting the decode contract run on the
/// existing Linux `swift` image with no xcframework download (sidesteps the
/// resolve-hang of 2026-04-26 and the macOS SPM mirror race). Consumers never
/// set this var, so iOS/macOS resolve the full, unchanged package.
let coreUIModelsTestOnly = ProcessInfo.processInfo.environment[
    "VAUCHI_COREUIMODELS_TEST_ONLY"
] != nil

/// Pure-Swift data types for core-driven screens (ScreenModel, Component,
/// UserAction, ActionResult, DesignTokens, component payloads). Depended on
/// by iOS and macOS so the two frontends share one canonical deserialization
/// surface instead of maintaining parallel `Vauchi/CoreUI/Models.swift`
/// copies. Problem: 2026-04-22-shared-coreui-models-package.
let coreUIModelsProduct: PackageDescription.Product = .library(
    name: "CoreUIModels",
    targets: ["CoreUIModels"]
)
let coreUIModelsTarget: PackageDescription.Target = .target(
    name: "CoreUIModels",
    path: "Sources/CoreUIModels"
)
let coreUIModelsTestTarget: PackageDescription.Target = .testTarget(
    name: "CoreUIModelsTests",
    dependencies: ["CoreUIModels"],
    path: "Tests/CoreUIModelsTests"
)

/// Swift bindings that wrap the FFI layer (Apple-only — depends on the
/// xcframework binary target).
let vauchiPlatformProduct: PackageDescription.Product = .library(
    name: "VauchiPlatform",
    targets: ["VauchiPlatform", "VauchiPlatformFFI"]
)
let vauchiPlatformTarget: PackageDescription.Target = .target(
    name: "VauchiPlatform",
    dependencies: ["VauchiPlatformFFI"],
    path: "Sources/VauchiPlatform"
)

let package = Package(
    name: "VauchiPlatform",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: coreUIModelsTestOnly
        ? [coreUIModelsProduct]
        : [vauchiPlatformProduct, coreUIModelsProduct],
    targets: coreUIModelsTestOnly
        ? [coreUIModelsTarget, coreUIModelsTestTarget]
        : [vauchiPlatformTarget, coreUIModelsTarget, coreUIModelsTestTarget, binaryTarget]
)
