// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Core ends a recovery link by withdrawing its advertisement. The bare string
/// was not decoded, so the shell saw `.unknown` and kept advertising
/// (vauchi/private#796).
final class BleStopAdvertisingDecodeTests: XCTestCase {
    func testBleStopAdvertisingDecodes() throws {
        let json = Data(#"{"Commands": {"commands": ["BleStopAdvertising"]}}"#.utf8)

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result,
              case .bleStopAdvertising = commands.first
        else {
            return XCTFail("Expected .commands([.bleStopAdvertising]), got \(result)")
        }
    }
}
