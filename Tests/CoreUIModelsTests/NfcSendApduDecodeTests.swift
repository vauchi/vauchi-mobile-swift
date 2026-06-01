// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Decode contract for `CommandDTO.nfcSendApdu` — the third NFC command
/// emitted by core in handshake phases 2/3 (`core .../exchange/nfc.rs`).
/// Mirrors the hand-written wire form `{"NfcSendApdu": {"data": [...]}}`
/// (see android `Models.kt` `NfcSendApdu` decode for the sibling mirror).
final class NfcSendApduDecodeTests: XCTestCase {
    func testNfcSendApduDecodesExactDataBytes() throws {
        // SELECT-AID APDU + 0x9000 trailer, the shape core frames in phase 2.
        let json = Data(#"{"Commands": {"commands": [{"NfcSendApdu": {"data": [0, 164, 4, 0, 144, 0]}}]}}"#.utf8)

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result else {
            return XCTFail("Expected .commands, got \(result)")
        }
        XCTAssertEqual(commands.count, 1)
        guard case let .nfcSendApdu(data) = commands[0] else {
            return XCTFail("Expected .nfcSendApdu, got \(commands[0])")
        }
        XCTAssertEqual(data, [0, 164, 4, 0, 144, 0])
    }

    func testNfcSendApduDecodesEmptyData() throws {
        let json = Data(#"{"Commands": {"commands": [{"NfcSendApdu": {"data": []}}]}}"#.utf8)

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result,
              case let .nfcSendApdu(data) = commands.first
        else {
            return XCTFail("Expected .commands([.nfcSendApdu]), got \(result)")
        }
        XCTAssertEqual(data, [])
    }
}
