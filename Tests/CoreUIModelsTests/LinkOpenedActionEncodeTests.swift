// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Wire contract for `UserAction::LinkOpened { uri }` (M5 B3).
/// Frontends forward every `vauchi://` deep link as this action;
/// core parses the URI and routes to the consent gate, device-link
/// join screen, or ShowAlert. The action encodes externally tagged
/// with a `uri` payload key, matching serde's default format.
final class LinkOpenedActionEncodeTests: XCTestCase {
    func testLinkOpenedEncodesExternallyTaggedWithUri() throws {
        let uri = "vauchi://device-link?qr=d2hhdGV2ZXI&code=QlJPS0VSNDI"
        let data = try JSONEncoder().encode(UserAction.linkOpened(uri: uri))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let payload = try XCTUnwrap(json["LinkOpened"] as? [String: Any])
        XCTAssertEqual(uri, payload["uri"] as? String)
    }
}
