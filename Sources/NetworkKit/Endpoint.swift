//
//  Endpoint.swift
//  NetworkKit
//

import Foundation

/// Describe una petición a un servicio. Cada servicio define su propio tipo conforme a `Endpoint`.
public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: (any Encodable)? { get }
}

extension Endpoint {
    public var method: HTTPMethod { .get }
    public var headers: [String: String] { [:] }
    public var queryItems: [URLQueryItem] { [] }
    public var body: (any Encodable)? { nil }

    /// Construye la `URLRequest` del endpoint.
    ///
    /// - Siempre agrega `Accept: application/json`.
    /// - Si hay body, lo codifica como JSON y agrega `Content-Type: application/json`.
    /// - Los headers del endpoint sobrescriben a los automáticos.
    public func makeURLRequest(encoder: JSONEncoder = JSONEncoder()) throws(NetworkError) -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw .invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw .invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw .encoding(error)
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        return request
    }
}
