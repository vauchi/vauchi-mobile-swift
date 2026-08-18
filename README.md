<!-- SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me> -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

> **Mirror:** This repo is a read-only mirror of [gitlab.com/vauchi/vauchi-platform-swift](https://gitlab.com/vauchi/vauchi-platform-swift). Please open issues and merge requests there.

[![Pipeline](https://vauchi.gitlab.io/vauchi-platform-swift/badges/pipeline.svg)](https://gitlab.com/vauchi/vauchi-platform-swift)
[![REUSE](https://api.reuse.software/badge/gitlab.com/vauchi/vauchi-platform-swift)](https://api.reuse.software/info/gitlab.com/vauchi/vauchi-platform-swift)

# VauchiPlatform Swift Package

Swift Package Manager distribution for VauchiPlatform iOS/macOS bindings.

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://gitlab.com/vauchi/vauchi-platform-swift.git", from: "0.1.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter the repository URL.

### Manual Installation

1. Download the XCFramework from [Releases](https://gitlab.com/vauchi/core/-/releases)
2. Drag `VauchiPlatformFFI.xcframework` into your Xcode project
3. Copy the Swift bindings from `Sources/VauchiPlatform/`

## Usage

```swift
import VauchiPlatform

// Initialize with documents storage
let vauchi = try VauchiPlatform.withDocumentsStorage()

// Or specify a custom path
let vauchi = try VauchiPlatform(storagePath: "/path/to/database.db")

// Create identity
try vauchi.createIdentity(password: "secure-password")

// Get public ID for sharing
let publicId = try vauchi.getPublicId()
```

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## Architecture Support

The XCFramework includes:

- `ios-arm64` - iOS devices
- `ios-arm64_x86_64-simulator` - iOS Simulator (Apple Silicon + Intel)

## License

GPL-3.0-or-later - see [LICENSE](LICENSE)

## Links

- [Main Repository](https://gitlab.com/vauchi/core)
- [Documentation](https://gitlab.com/vauchi/docs)
- [Issues](https://gitlab.com/vauchi/vauchi/-/issues)
