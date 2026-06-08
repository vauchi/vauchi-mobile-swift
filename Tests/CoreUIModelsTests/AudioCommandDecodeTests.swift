// SPDX-FileCopyrightText: 2026 Mattia Egloff <mattia.egloff@pm.me>
//
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import CoreUIModels
import XCTest

/// Decode contract for the audio-proximity commands core emits for the
/// ultrasonic ranging in Hover / Bump / Shake exchanges
/// (`core/vauchi-core/src/platform.rs`):
///
///   `AudioEmitChallenge   { samples: Vec<f32>, sample_rate: u32 }`
///   `AudioListenForResponse { timeout_ms: u64, sample_rate: u32 }`
///   `AudioStop`
///
/// `coreJSONDecoder` applies `.convertFromSnakeCase`, so the wire keys
/// `sample_rate` / `timeout_ms` resolve to the camelCase fields. This pins
/// the fix for the stale `data: [UInt8]` shape that never matched the wire
/// and silently decoded to `.unknown` (the same bug Android hit as an NPE).
final class AudioCommandDecodeTests: XCTestCase {
    func testAudioEmitChallengeDecodesSamplesAndRate() throws {
        let json = Data(#"""
        {"Commands": {"commands": [{"AudioEmitChallenge": {"samples": [0.5, -0.25, 1.0, 0.0], "sample_rate": 44100}}]}}
        """#.utf8)

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result else {
            return XCTFail("Expected .commands, got \(result)")
        }
        XCTAssertEqual(commands.count, 1)
        guard case let .audioEmitChallenge(samples, sampleRate) = commands[0] else {
            return XCTFail("Expected .audioEmitChallenge, got \(commands[0])")
        }
        XCTAssertEqual(samples, [0.5, -0.25, 1.0, 0.0])
        XCTAssertEqual(sampleRate, 44100)
    }

    func testAudioListenForResponseDecodesTimeoutAndRate() throws {
        let json = Data(#"""
        {"Commands": {"commands": [{"AudioListenForResponse": {"timeout_ms": 2500, "sample_rate": 48000}}]}}
        """#.utf8)

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result,
              case let .audioListenForResponse(timeoutMs, sampleRate) = commands.first
        else {
            return XCTFail("Expected .commands([.audioListenForResponse]), got \(result)")
        }
        XCTAssertEqual(timeoutMs, 2500)
        XCTAssertEqual(sampleRate, 48000)
    }

    func testAudioEmitChallengeDecodesEmptySamples() throws {
        let json = Data(#"""
        {"Commands": {"commands": [{"AudioEmitChallenge": {"samples": [], "sample_rate": 44100}}]}}
        """#.utf8)

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result,
              case let .audioEmitChallenge(samples, sampleRate) = commands.first
        else {
            return XCTFail("Expected .commands([.audioEmitChallenge]), got \(result)")
        }
        XCTAssertEqual(samples, [])
        XCTAssertEqual(sampleRate, 44100)
    }

    func testAudioStopDecodesAsBareString() throws {
        let json = Data(#"{"Commands": {"commands": ["AudioStop"]}}"#.utf8)

        let result = try coreJSONDecoder.decode(ActionResult.self, from: json)

        guard case let .commands(commands) = result,
              case .audioStop = commands.first
        else {
            return XCTFail("Expected .commands([.audioStop]), got \(result)")
        }
        XCTAssertEqual(commands.count, 1)
    }
}
