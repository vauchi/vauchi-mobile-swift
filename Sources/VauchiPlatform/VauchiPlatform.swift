// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// VauchiPlatform - Swift bindings for Vauchi
//
// This file re-exports the UniFFI-generated bindings from the FFI layer.
// The actual implementation is in the VauchiPlatformFFI XCFramework.
//
// Usage:
//   import VauchiPlatform
//   let vauchi = try VauchiPlatform(dataDir: "...", relayUrl: "...")

import Foundation
@_exported import VauchiPlatformFFI
