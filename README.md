# VauchiMobile Swift Package

Swift Package Manager distribution for VauchiMobile iOS/macOS bindings.

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://gitlab.com/vauchi/vauchi-mobile-swift.git", from: "0.1.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter the repository URL.

### Manual Installation

1. Download the XCFramework from [Releases](https://gitlab.com/vauchi/core/-/releases)
2. Drag `VauchiMobileFFI.xcframework` into your Xcode project
3. Copy the Swift bindings from `Sources/VauchiMobile/`

## Usage

```swift
import VauchiMobile

// Initialize with documents storage
let vauchi = try VauchiMobile.withDocumentsStorage()

// Or specify a custom path
let vauchi = try VauchiMobile(storagePath: "/path/to/database.db")

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

MIT License - see [LICENSE](LICENSE)

## Links

- [Main Repository](https://gitlab.com/vauchi/core)
- [Documentation](https://gitlab.com/vauchi/docs)
- [Issues](https://gitlab.com/vauchi/vauchi/-/issues)
