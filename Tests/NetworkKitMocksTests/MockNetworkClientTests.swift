//
//  MockNetworkClientTests.swift
//  NetworkKitMocksTests
//

import Foundation
import Testing
import NetworkKit
import NetworkKitMocks

private struct ItemList: Codable, Equatable, Sendable {
    struct Item: Codable, Equatable, Sendable {
        let id: String
        let title: String
    }
    let items: [Item]

    static let dummy = ItemList(items: [
        Item(id: "a", title: "Dummy A"),
        Item(id: "b", title: "Dummy B"),
    ])
}

private struct ListItemsEndpoint: Endpoint {
    let baseURL = "https://api.example.com"
    let path = "/items"
}

private struct DeleteItemEndpoint: Endpoint {
    let baseURL = "https://api.example.com"
    let path = "/items/1"
    let method: HTTPMethod = .delete
}

struct MockNetworkClientTests {

    @Test func respondsWithJSONString() async throws {
        let client = MockNetworkClient(json: #"{ "items": [ { "id": "9", "title": "Desde string" } ] }"#)

        let list: ItemList = try await client.request(ListItemsEndpoint())

        #expect(list.items.map(\.id) == ["9"])
    }

    @Test func respondsWithBundledJSONFile() async throws {
        let client = try MockNetworkClient(jsonFile: "items", bundle: .module)

        let list: ItemList = try await client.request(ListItemsEndpoint())

        #expect(list.items.count == 3)
        #expect(list.items.first?.id == "1")
    }

    @Test func respondsWithDummyObject() async throws {
        let client = try MockNetworkClient(response: ItemList.dummy)

        let list: ItemList = try await client.request(ListItemsEndpoint())

        #expect(list == ItemList.dummy)
    }

    @Test func respondMethodsReplaceTheResponse() async throws {
        let client = MockNetworkClient(json: #"{ "items": [] }"#)
        try client.respond(with: ItemList.dummy)

        let list: ItemList = try await client.request(ListItemsEndpoint())

        #expect(list == ItemList.dummy)
    }

    @Test func missingJSONFileThrowsFileNotFound() {
        #expect(throws: MockNetworkClient.MockDataError.self) {
            try MockNetworkClient(jsonFile: "no_existe", bundle: .module)
        }
    }

    @Test func configuredErrorIsThrownAndRequestIsRecorded() async {
        let client = MockNetworkClient(error: .httpStatus(code: 500, data: Data()))

        do {
            let _: ItemList = try await client.request(ListItemsEndpoint())
            Issue.record("Se esperaba un error")
        } catch {
            guard case .httpStatus(500, _)? = error as? NetworkError else {
                Issue.record("Se esperaba .httpStatus(500) y llegó \(error)")
                return
            }
        }
        #expect(client.receivedRequests.count == 1)
    }

    @Test func noContentRequestIsRecorded() async throws {
        let client = MockNetworkClient()

        try await client.request(DeleteItemEndpoint())

        let request = try #require(client.receivedRequests.first)
        #expect(request.httpMethod == "DELETE")
        #expect(request.url?.absoluteString == "https://api.example.com/items/1")
    }
}
