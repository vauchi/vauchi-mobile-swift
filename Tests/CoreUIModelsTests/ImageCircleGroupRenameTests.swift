// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Decode/encode contract for the core!1359 (avatar → `ImageCircle`) and
/// core!1360 (group → variant/scopes) wire renames. This mirror shipped
/// STALE in v0.52.8 — it decoded the pre-rename keys, so the release's own
/// xcframework (emitting the new keys) could not be decoded. These cases
/// pin the current core wire (`vauchi-app/src/ui/{component,action}`) so a
/// future rename can't silently drift the hand-maintained mirror again.
final class ImageCircleGroupRenameTests: XCTestCase {
    func testImageCircleComponentDecodesWithEditActionId() throws {
        let json = Data("""
        {"ImageCircle": {"id": "avatar", "image_data": [1, 2, 3], "initials": "AS", \
        "bg_color": [10, 20, 30], "brightness": 0.0, "editable": true, \
        "edit_action_id": "edit_avatar"}}
        """.utf8)
        let component = try coreJSONDecoder.decode(Component.self, from: json)
        guard case let .imageCircle(circle) = component else {
            return XCTFail("expected .imageCircle, got \(component)")
        }
        XCTAssertEqual([1, 2, 3], circle.imageData)
        XCTAssertEqual("AS", circle.initials)
        XCTAssertEqual("edit_avatar", circle.editActionId)
        XCTAssertTrue(circle.editable)
    }

    func testImageCircleDecodesWithoutEditActionId() throws {
        let json = Data("""
        {"ImageCircle": {"id": "avatar", "initials": "A", "brightness": 0.0, "editable": false}}
        """.utf8)
        let component = try coreJSONDecoder.decode(Component.self, from: json)
        guard case let .imageCircle(circle) = component else {
            return XCTFail("expected .imageCircle, got \(component)")
        }
        XCTAssertNil(circle.editActionId)
        XCTAssertNil(circle.imageData)
    }

    func testFieldListDecodesAvailableScopes() throws {
        let json = Data("""
        {"FieldList": {"id": "fields", "fields": [], "visibility_mode": "ShowHide", \
        "available_scopes": ["work", "family"]}}
        """.utf8)
        let component = try coreJSONDecoder.decode(Component.self, from: json)
        guard case let .fieldList(list) = component else {
            return XCTFail("expected .fieldList, got \(component)")
        }
        XCTAssertEqual(["work", "family"], list.availableScopes)
    }

    func testUiFieldVisibilityDecodesScopes() throws {
        let visibility = try coreJSONDecoder.decode(
            UiFieldVisibility.self,
            from: Data(#"{"Scopes": ["work"]}"#.utf8)
        )
        guard case let .scopes(scopes) = visibility else {
            return XCTFail("expected .scopes, got \(visibility)")
        }
        XCTAssertEqual(["work"], scopes)
    }

    func testPreviewDecodesImageData() throws {
        let json = Data("""
        {"Preview": {"name": "Alice", "initials": "A", "image_data": [7, 8, 9], \
        "fields": [], "variants": [], "selected_variant": null}}
        """.utf8)
        let component = try coreJSONDecoder.decode(Component.self, from: json)
        guard case let .preview(preview) = component else {
            return XCTFail("expected .preview, got \(component)")
        }
        XCTAssertEqual([7, 8, 9], preview.imageData)
    }

    func testVariantSelectedEncodesExternallyTagged() throws {
        let data = try JSONEncoder().encode(UserAction.variantSelected(variantId: "work"))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let payload = try XCTUnwrap(json["VariantSelected"] as? [String: Any])
        XCTAssertEqual("work", payload["variant_id"] as? String)
    }

    func testVariantSelectedEncodesNilVariantId() throws {
        let data = try JSONEncoder().encode(UserAction.variantSelected(variantId: nil))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let payload = try XCTUnwrap(json["VariantSelected"] as? [String: Any])
        XCTAssertNil(payload["variant_id"])
    }
}
