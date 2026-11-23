//
//  EndpointTests.swift
//  NetworkKitTests
//

import Foundation
import Testing
import NetworkKit

/// Endpoint configurable para probar `makeURLRequest`.
private struct TestEndpoint: Endpoint {
    var baseURL = "https://api.example.com"
    var path = "/items"
    var method: HTTPMethod = .get
    var headers: [String: String] = [:]
    var queryItems: [URLQueryItem] = []
    var body: (any Encodable)? = nil
}

/// Endpoint que solo define lo obligatorio, para comprobar los valores por defecto.
private struct MinimalEndpoint: Endpoint {
    let baseURL = "https://api.example.com"
    let path = "/items"
}

private struct Payload: Codable, Equatable {
    let name: String
    let count: Int
}

private struct FailingBody: Encodable {
    struct Failure: Error {}
    func encode(to encoder: any Encoder) throws { throw Failure() }
}

struct EndpointTests {

    @Test func defaultsProduceGetWithAcceptHeaderAndNoBody() throws {
        let request = try MinimalEndpoint().makeURLRequest()

        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "https://api.example.com/items")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
        #expect(request.httpBody == nil)
    }

    @Test(arguments: [
        (HTTPMethod.get, "GET"),
        (.post, "POST"),
        (.put, "PUT"),
        (.patch, "PATCH"),
        (.delete, "DELETE"),
    ])
    func usesTheEndpointMethod(method: HTTPMethod, expected: String) throws {
        let request = try TestEndpoint(method: method).makeURLRequest()
        #expect(request.httpMethod == expected)
    }

    @Test func appendsQueryItemsToTheURL() throws {
        let endpoint = TestEndpoint(queryItems: [
            URLQueryItem(name: "tags", value: "front_page"),
            URLQueryItem(name: "page", value: "2"),
        ])

        let request = try endpoint.makeURLRequest()

        #expect(request.url?.absoluteString == "https://api.example.com/items?tags=front_page&page=2")
    }

    @Test func encodesBodyAsJSONWithContentType() throws {
        let payload = Payload(name: "post", count: 3)
        let endpoint = TestEndpoint(method: .post, body: payload)

        let request = try endpoint.makeURLRequest()

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let body = try #require(request.httpBody)
        #expect(try JSONDecoder().decode(Payload.self, from: body) == payload)
    }

    @Test func endpointHeadersOverrideAutomaticOnes() throws {
        let endpoint = TestEndpoint(headers: ["Accept": "text/plain", "X-Token": "abc"])

        let request = try endpoint.makeURLRequest()

        #expect(request.value(forHTTPHeaderField: "Accept") == "text/plain")
        #expect(request.value(forHTTPHeaderField: "X-Token") == "abc")
    }

    @Test func bodyThatFailsToEncodeThrowsEncodingError() {
        let endpoint = TestEndpoint(method: .post, body: FailingBody())

        do {
            _ = try endpoint.makeURLRequest()
            Issue.record("Se esperaba NetworkError.encoding")
        } catch {
            guard case .encoding = error else {
                Issue.record("Se esperaba .encoding y llegó \(error)")
                return
            }
        }
    }
}
