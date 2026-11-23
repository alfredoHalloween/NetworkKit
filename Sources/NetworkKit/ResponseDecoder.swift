//
//  ResponseDecoder.swift
//  NetworkKit
//

import Foundation

/// Decodifica respuestas de red fuera del main actor.
///
/// `decode` está marcado `@concurrent`, así que siempre se ejecuta en el pool de hilos global
/// aunque se llame desde el main actor. Los tipos decodificados deben ser `nonisolated` y `Sendable`.
public struct ResponseDecoder: Sendable {
    public let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    @concurrent
    public func decode<T: Decodable & Sendable>(_ type: T.Type, from data: Data) async throws(NetworkError) -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw .decoding(error)
        }
    }
}
