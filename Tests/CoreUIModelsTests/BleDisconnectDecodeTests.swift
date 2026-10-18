// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Decode contract for `CommandDTO.bleDisconnect`. Core addresses the link
/// it drops, `{"BleDisconnect": {"device_id": …, "direction": …}}`
/// (`core .../platform.rs`); only the bare string was decoded, so every
/// disconnect reached the shell as `.unknown` and an iPhone that dialled a
/// Glance kept its link up (vauchi/private#673).
final class BleDisconnectDecodeTests: XCTestCase {
    func testAddressedBleDisconnectDecodes() throws {
        let json = Data(
            #"{"Commands": {"commands": [{"BleDisconnect": {"device_id": "52:52:DF:07:D2:AC", "direction": "Outbound"}}]}}"#
                .utf8
        )

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result else {
            return XCTFail("Expected .commands, got \(result)")
        }
        XCTAssertEqual(commands.count, 1)
        guard case .bleDisconnect = commands[0] else {
            return XCTFail("Expected .bleDisconnect, got \(commands[0])")
        }
    }

    func testBareBleDisconnectStillDecodes() throws {
        let json = Data(#"{"Commands": {"commands": ["BleDisconnect"]}}"#.utf8)

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result,
              case .bleDisconnect = commands.first
        else {
            return XCTFail("Expected .commands([.bleDisconnect]), got \(result)")
        }
    }
}
