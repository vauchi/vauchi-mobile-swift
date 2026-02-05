// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "0.1.11"
let checksum = "6cf0400fd3c42b8b864af468844d292a8bc119dba6096e83fab0ad63e7f45985"  // Updated by CI on release

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
