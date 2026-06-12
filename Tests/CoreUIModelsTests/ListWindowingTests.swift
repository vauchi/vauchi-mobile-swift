// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Wire contract for `Component::List` windowing and the
/// `ListWindowRequested` prefetch action (Track B of
/// `2026-06-11-contacts-list-eager-render-anr`). Core skip-serializes
/// zero windowing fields, so absence must decode as unwindowed — the
/// exact pre-windowing wire shape. The action encodes externally
/// tagged with snake_case payload keys, like every other `UserAction`.
final class ListWindowingTests: XCTestCase {
    private func listJSON(windowLine: String) -> Data {
        Data("""
        {"List": {"id": "contacts", "items": [], "searchable": true\(windowLine)}}
        """.utf8)
    }

    func testListWithoutWindowFieldsDecodesUnwindowed() throws {
        let component = try coreJSONDecoder.decode(Component.self, from: listJSON(windowLine: ""))
        guard case let .list(list) = component else {
            return XCTFail("expected .list, got \(component)")
        }
        XCTAssertEqual(0, list.totalCount)
        XCTAssertEqual(0, list.offset)
        XCTAssertEqual(0, list.window)
    }

    func testWindowedListDecodesWindowFields() throws {
        let component = try coreJSONDecoder.decode(
            Component.self,
            from: listJSON(windowLine: #", "total_count": 500, "offset": 200, "window": 200"#)
        )
        guard case let .list(list) = component else {
            return XCTFail("expected .list, got \(component)")
        }
        XCTAssertEqual(500, list.totalCount)
        XCTAssertEqual(200, list.offset)
        XCTAssertEqual(200, list.window)
    }

    func testListWindowRequestedEncodesExternallyTagged() throws {
        let data = try JSONEncoder().encode(
            UserAction.listWindowRequested(componentId: "contacts", offset: 150)
        )
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let payload = try XCTUnwrap(json["ListWindowRequested"] as? [String: Any])
        XCTAssertEqual("contacts", payload["component_id"] as? String)
        XCTAssertEqual(150, payload["offset"] as? Int)
    }
}
