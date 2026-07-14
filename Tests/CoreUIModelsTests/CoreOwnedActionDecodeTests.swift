// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
// SPDX-License-Identifier: GPL-3.0-or-later

import CoreUIModels
import Foundation
import XCTest

final class CoreOwnedActionDecodeTests: XCTestCase {
    private func decode(_ json: String) throws -> Component {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Component.self, from: Data(json.utf8))
    }

    func testInlineConfirmPreservesOpaqueActionIds() throws {
        let component = try decode(#"""
        {
            "InlineConfirm": {
                "id": "visual-only-id",
                "warning": "Continue?",
                "confirm_text": "Yes",
                "cancel_text": "No",
                "confirm_action_id": "opaque/confirm#7",
                "cancel_action_id": "opaque/cancel#8",
                "destructive": false
            }
        }
        """#)

        guard case let .inlineConfirm(value) = component else {
            return XCTFail("Expected InlineConfirm")
        }
        XCTAssertEqual(value.confirmActionId, "opaque/confirm#7")
        XCTAssertEqual(value.cancelActionId, "opaque/cancel#8")
    }

    func testEditableTextPreservesCoreCopyAndOpaqueActionIds() throws {
        let component = try decode(#"""
        {
            "EditableText": {
                "id": "visual-only-id",
                "label": "Note",
                "value": "Hello",
                "edit_text": "Change note",
                "save_text": "Keep it",
                "cancel_text": "Leave it",
                "edit_action_id": "opaque/edit#1",
                "save_action_id": "opaque/save#2",
                "cancel_action_id": "opaque/cancel#3",
                "editing": false,
                "validation_error": null
            }
        }
        """#)

        guard case let .editableText(value) = component else {
            return XCTFail("Expected EditableText")
        }
        XCTAssertEqual(value.editText, "Change note")
        XCTAssertEqual(value.saveText, "Keep it")
        XCTAssertEqual(value.cancelText, "Leave it")
        XCTAssertEqual(value.editActionId, "opaque/edit#1")
        XCTAssertEqual(value.saveActionId, "opaque/save#2")
        XCTAssertEqual(value.cancelActionId, "opaque/cancel#3")
    }

    func testImageCirclePreservesOpaqueEditActionId() throws {
        let component = try decode(#"""
        {
            "ImageCircle": {
                "id": "visual-only-id",
                "image_data": null,
                "initials": "AG",
                "brightness": 0.0,
                "editable": true,
                "edit_action_id": "opaque/image-edit#4"
            }
        }
        """#)

        guard case let .imageCircle(value) = component else {
            return XCTFail("Expected ImageCircle")
        }
        XCTAssertEqual(value.editActionId, "opaque/image-edit#4")
    }

    func testStatusIndicatorPreservesCoreLocalizedLabel() throws {
        let component = try decode(#"""
        {
            "StatusIndicator": {
                "id": "sync-status",
                "icon": null,
                "title": "Synchronisation",
                "detail": null,
                "status": "Success",
                "status_label": "Erfolg"
            }
        }
        """#)

        guard case let .statusIndicator(value) = component else {
            return XCTFail("Expected StatusIndicator")
        }
        XCTAssertEqual(value.statusLabel, "Erfolg")
    }
}
