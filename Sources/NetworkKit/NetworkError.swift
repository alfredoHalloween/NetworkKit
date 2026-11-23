//
//  NetworkError.swift
//  NetworkKit
//

import Foundation

/// Errores tipados de la capa de red.
public enum NetworkError: Error, Sendable {
    /// No se pudo construir una URL válida a partir del `Endpoint`.
    case invalidURL
    /// La respuesta no es una `HTTPURLResponse`.
    case invalidResponse
    /// El servidor respondió con un código fuera de `200..<300`.
    case httpStatus(code: Int, data: Data)
    /// No se pudo codificar el body como JSON.
    case encoding(any Error)
    /// No se pudo decodificar la respuesta.
    case decoding(any Error)
    /// Error de transporte de `URLSession` (sin conexión, timeout, ATS, etc.).
    case transport(any Error)
}
