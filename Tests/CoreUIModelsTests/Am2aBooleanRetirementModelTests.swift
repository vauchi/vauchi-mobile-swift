// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Wire contract tests for ADR-044 Amendment 2a additions:
/// `UserAction::NavigateBack`, `ActionResult::PerformNativeBack`,
/// `CommandDTO::ScheduleWakeup`, `ScreenModel.navActions`, and
/// `ScreenModel.navTabId`.
final class Am2aBooleanRetirementModelTests: XCTestCase {
    // MARK: - UserAction

    func testNavigateBackEncodesExternallyTaggedWithEmptyPayload() throws {
        let data = try JSONEncoder().encode(UserAction.navigateBack)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let payload = try XCTUnwrap(json["NavigateBack"] as? [String: Any])
        XCTAssertTrue(payload.isEmpty)
    }

    // MARK: - ActionResult

    func testPerformNativeBackDecodesAsBareString() throws {
        let json = Data("\"PerformNativeBack\"".utf8)
        let result = try JSONDecoder().decode(ActionResult.self, from: json)
        guard case .performNativeBack = result else {
            XCTFail("Expected .performNativeBack, got \(result)")
            return
        }
    }

    // MARK: - CommandDTO

    func testScheduleWakeupDecodesRelativeSeconds() throws {
        let json = """
        {
            "ScheduleWakeup": {
                "earliest_secs": 10,
                "deadline_secs": 60,
                "min_interval_secs": 30
            }
        }
        """.data(using: .utf8)!
        let command = try coreJSONDecoder.decode(CommandDTO.self, from: json)
        guard case let .scheduleWakeup(earliestSecs, deadlineSecs, minIntervalSecs) = command else {
            XCTFail("Expected .scheduleWakeup, got \(command)")
            return
        }
        XCTAssertEqual(earliestSecs, 10)
        XCTAssertEqual(deadlineSecs, 60)
        XCTAssertEqual(minIntervalSecs, 30)
    }

    // MARK: - ScreenModel chrome

    func testScreenModelDecodesNavActionsAndNavTabId() throws {
        let json = """
        {
            "screen_id": "my_info",
            "title": "My Info",
            "components": [],
            "actions": [],
            "nav_actions": [
                {
                    "id": "go_back",
                    "label": "Back",
                    "style": "Secondary",
                    "enabled": true
                }
            ],
            "nav_tab_id": "my_info"
        }
        """.data(using: .utf8)!
        let screen = try coreJSONDecoder.decode(ScreenModel.self, from: json)
        XCTAssertEqual(screen.navActions.count, 1)
        XCTAssertEqual(screen.navActions.first?.id, "go_back")
        XCTAssertEqual(screen.navTabId, "my_info")
    }

    func testScreenModelDefaultsNavActionsAndNavTabIdWhenAbsent() throws {
        let json = """
        {
            "screen_id": "onboarding_welcome",
            "title": "Welcome",
            "components": [],
            "actions": []
        }
        """.data(using: .utf8)!
        let screen = try coreJSONDecoder.decode(ScreenModel.self, from: json)
        XCTAssertTrue(screen.navActions.isEmpty)
        XCTAssertNil(screen.navTabId)
    }
}
