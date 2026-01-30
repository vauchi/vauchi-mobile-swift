// VauchiMobile - Swift bindings for Vauchi
//
// This file re-exports the UniFFI-generated bindings from the FFI layer.
// The actual implementation is in the VauchiMobileFFI XCFramework.
//
// Usage:
//   import VauchiMobile
//   let vauchi = try VauchiMobile(dataDir: "...", relayUrl: "...")

import Foundation
@_exported import VauchiMobileFFI
