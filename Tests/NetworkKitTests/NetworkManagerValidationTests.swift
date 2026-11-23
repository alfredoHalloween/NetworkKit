//
//  NetworkManagerValidationTests.swift
//  NetworkKitTests
//

import Foundation
import Testing
import NetworkKit

struct NetworkManagerValidationTests {

    private let url = URL(string: "https://api.example.com")!
    private let data = Data("payload".utf8)

    private func response(status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }

    @Test(arguments: [200, 201, 204, 299])
    func successStatusReturnsTheData(status: Int) throws {
        let result = try NetworkManager.validate(data: data, response: response(status: status))
        #expect(result == data)
    }

    @Test(arguments: [100, 199, 300, 304, 400, 404, 500, 503])
    func nonSuccessStatusThrowsHTTPStatus(status: Int) {
        do {
            _ = try NetworkManager.validate(data: data, response: response(status: status))
            Issue.record("Se esperaba NetworkError.httpStatus")
        } catch {
            guard case let .httpStatus(code, body) = error else {
                Issue.record("Se esperaba .httpStatus y llegó \(error)")
                return
            }
            #expect(code == status)
            #expect(body == data)
        }
    }

    @Test func nonHTTPResponseThrowsInvalidResponse() {
        let plain = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        do {
            _ = try NetworkManager.validate(data: data, response: plain)
            Issue.record("Se esperaba NetworkError.invalidResponse")
        } catch {
            guard case .invalidResponse = error else {
                Issue.record("Se esperaba .invalidResponse y llegó \(error)")
                return
            }
        }
    }
}
