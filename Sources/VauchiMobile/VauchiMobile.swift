// VauchiMobile - Swift bindings for Vauchi
//
// This file re-exports the UniFFI-generated bindings from the FFI layer.
// The actual implementation is in the VauchiMobileFFI XCFramework.
//
// Usage:
//   import VauchiMobile
//   let vauchi = try VauchiMobile(storagePath: "...")

@_exported import VauchiMobileFFI

// MARK: - Convenience Extensions

extension VauchiMobile {
    /// Initialize VauchiMobile with a storage path in the app's documents directory.
    ///
    /// - Parameter name: Database name (default: "vauchi")
    /// - Returns: Configured VauchiMobile instance
    public static func withDocumentsStorage(name: String = "vauchi") throws -> VauchiMobile {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storagePath = documentsPath.appendingPathComponent("\(name).db").path
        return try VauchiMobile(storagePath: storagePath)
    }
}
