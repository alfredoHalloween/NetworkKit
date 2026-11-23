//
//  NetworkManager.swift
//  NetworkKit
//

import Foundation

/// Implementación de `NetworkClient` sobre `URLSession`.
public final class NetworkManager: NetworkClient, Sendable {

    private let session: URLSession
    private let responseDecoder: ResponseDecoder
    private let encoder: JSONEncoder

    public init(
        session: URLSession = .shared,
        responseDecoder: ResponseDecoder = ResponseDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.responseDecoder = responseDecoder
        self.encoder = encoder
    }

    public func request<T: Decodable & Sendable>(_ endpoint: some Endpoint) async throws -> T {
        let data = try await perform(endpoint)
        return try await responseDecoder.decode(T.self, from: data)
    }

    public func request(_ endpoint: some Endpoint) async throws {
        _ = try await perform(endpoint)
    }

    /// Valida que la respuesta sea HTTP y que su código esté en `200..<300`.
    public static func validate(data: Data, response: URLResponse) throws(NetworkError) -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw .httpStatus(code: httpResponse.statusCode, data: data)
        }
        return data
    }

    private func perform(_ endpoint: some Endpoint) async throws(NetworkError) -> Data {
        let request = try endpoint.makeURLRequest(encoder: encoder)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw .transport(error)
        }
        return try Self.validate(data: data, response: response)
    }
}
