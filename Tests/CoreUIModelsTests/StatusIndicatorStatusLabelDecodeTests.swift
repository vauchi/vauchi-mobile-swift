// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Wire contract test for `StatusIndicatorComponent.statusLabel` (core!1355).
///
/// Core resolves the badge label from the `status` discriminant and ships it
/// as `status_label`; frontends render it verbatim instead of deriving text
/// from the enum value.
final class StatusIndicatorStatusLabelDecodeTests: XCTestCase {
    func testStatusLabelDecodesFromWire() throws {
        let json = Data("""
        {
            "id": "si1",
            "title": "Sync",
            "status": "Success",
            "status_label": "Synchronisiert"
        }
        """.utf8)

        let indicator = try coreJSONDecoder.decode(StatusIndicatorComponent.self, from: json)
        XCTAssertEqual(indicator.statusLabel, "Synchronisiert")
    }

    func testStatusLabelDefaultsToEmptyWhenAbsent() throws {
        let json = Data("""
        {
            "id": "si1",
            "title": "Sync",
            "status": "Success"
        }
        """.utf8)

        let indicator = try coreJSONDecoder.decode(StatusIndicatorComponent.self, from: json)
        XCTAssertEqual(indicator.statusLabel, "")
    }
}
