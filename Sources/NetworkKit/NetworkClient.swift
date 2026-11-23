//
//  NetworkClient.swift
//  NetworkKit
//

/// Abstracción del cliente HTTP. `NetworkManager` es la implementación real
/// y `MockNetworkClient` (módulo `NetworkKitMocks`) la de previews y tests.
public protocol NetworkClient {
    /// Ejecuta la petición y decodifica la respuesta (fuera del main actor) como `T`.
    func request<T: Decodable & Sendable>(_ endpoint: some Endpoint) async throws -> T
    /// Ejecuta la petición sin decodificar la respuesta (DELETE / 204).
    func request(_ endpoint: some Endpoint) async throws
}
