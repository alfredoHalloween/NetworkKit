//
//  ResponseDecoderTests.swift
//  NetworkKitTests
//

import Foundation
import Testing
import NetworkKit

private struct Item: Decodable, Sendable {
    let id: Int
    let name: String?
}

/// Registra en qué hilo se ejecuta su `init(from:)`.
private struct DecodingThreadProbe: Decodable, Sendable {
    let decodedOnMainThread: Bool

    init(from decoder: any Decoder) throws {
        decodedOnMainThread = Thread.isMainThread
    }
}

struct ResponseDecoderTests {

    @Test func decodesValidJSON() async throws {
        let json = #"[ { "id": 1, "name": "Hola" }, { "id": 2, "name": null } ]"#

        let items = try await ResponseDecoder().decode([Item].self, from: Data(json.utf8))

        #expect(items.count == 2)
        #expect(items.first?.name == "Hola")
        #expect(items.last?.name == nil)
    }

    @Test func invalidJSONThrowsDecodingError() async {
        do {
            _ = try await ResponseDecoder().decode([Item].self, from: Data("no es json".utf8))
            Issue.record("Se esperaba NetworkError.decoding")
        } catch {
            guard case .decoding = error else {
                Issue.record("Se esperaba .decoding y llegó \(error)")
                return
            }
        }
    }

    @MainActor
    @Test func decodesOffTheMainThreadEvenWhenCalledFromMainActor() async throws {
        MainActor.assertIsolated()

        let probe = try await ResponseDecoder().decode(DecodingThreadProbe.self, from: Data("{}".utf8))

        #expect(probe.decodedOnMainThread == false)
    }
}
