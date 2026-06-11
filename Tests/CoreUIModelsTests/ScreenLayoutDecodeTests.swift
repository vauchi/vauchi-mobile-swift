// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Decode contract for `ScreenModel.layout`
/// (`core/vauchi-app/src/ui/screen.rs` `ScreenLayout`): omitted on the
/// wire when `Scroll`; `"Fixed"` for QR-stability screens; `"Pinned"`
/// for screens whose list component owns scrolling (design
/// `2026-06-11-contacts-list-windowing`). The enum decoder throws on
/// unknown raw values, so every core variant must exist here before a
/// core release emits it.
final class ScreenLayoutDecodeTests: XCTestCase {
    private func screenJSON(layoutLine: String) -> Data {
        Data("""
        {"screen_id": "contacts", "title": "Contacts", "components": [], "actions": []\(layoutLine)}
        """.utf8)
    }

    func testLayoutDefaultsToScrollWhenAbsent() throws {
        let screen = try coreJSONDecoder.decode(ScreenModel.self, from: screenJSON(layoutLine: ""))
        XCTAssertEqual(ScreenLayout.scroll, screen.layout)
    }

    func testFixedLayoutDecodes() throws {
        let screen = try coreJSONDecoder.decode(
            ScreenModel.self,
            from: screenJSON(layoutLine: #", "layout": "Fixed""#)
        )
        XCTAssertEqual(ScreenLayout.fixed, screen.layout)
    }

    func testPinnedLayoutDecodes() throws {
        let screen = try coreJSONDecoder.decode(
            ScreenModel.self,
            from: screenJSON(layoutLine: #", "layout": "Pinned""#)
        )
        XCTAssertEqual(ScreenLayout.pinned, screen.layout)
    }
}
