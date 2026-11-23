# NetworkKit

Cliente HTTP ligero para Swift, basado en `async/await` y sin dependencias de terceros.

- **`NetworkKit`**: `Endpoint`, `HTTPMethod`, `NetworkClient`, `NetworkManager` (sobre `URLSession`), `NetworkError` y `ResponseDecoder`.
- **`NetworkKitMocks`**: `MockNetworkClient`, para previews y tests sin red.

Requiere Swift 6.2 o posterior, iOS 17+ o macOS 14+.

## Instalación

Swift Package Manager:

```swift
.package(url: "https://github.com/alfredoHalloween/NetworkKit.git", from: "1.0.0")
```

Agrega el producto `NetworkKit` al target de la app y `NetworkKitMocks` donde uses el mock (la app, si lo usas en previews, o el target de tests).

## Uso

### Definir un endpoint

```swift
import Foundation
import NetworkKit

nonisolated enum PostEndpoint: Endpoint {
    case frontPage
    case create(NewPost)

    var baseURL: String { "https://api.example.com" }

    var path: String {
        switch self {
        case .frontPage: "/posts"
        case .create: "/posts"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .frontPage: .get
        case .create: .post
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .frontPage: nil
        case .create(let post): post
        }
    }
}
```

Los valores por defecto son: método GET, sin headers, sin query items y sin body. `makeURLRequest()` siempre agrega `Accept: application/json` y, si hay body, lo codifica como JSON con `Content-Type: application/json`. Los headers del endpoint mandan sobre los automáticos.

### Hacer peticiones

```swift
let client: any NetworkClient = NetworkManager()

let posts: [Post] = try await client.request(PostEndpoint.frontPage)  // decodifica la respuesta
try await client.request(PostEndpoint.create(newPost))                // sin decodificar la respuesta (p. ej. 204)
```

`NetworkManager` valida que la respuesta sea HTTP 2xx. Los errores llegan como `NetworkError`: `invalidURL`, `invalidResponse`, `httpStatus(code:data:)`, `encoding`, `decoding` o `transport`.

### Modelos de respuesta

Las respuestas se decodifican **fuera del main actor**, porque `ResponseDecoder.decode` es `@concurrent`. Por eso los modelos tienen que ser `Sendable`. Si tu target usa `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, decláralos también `nonisolated`:

```swift
nonisolated struct Post: Codable, Sendable {
    let id: String
    let title: String
}
```

Lo mismo aplica a los tipos que conforman `Endpoint` en un target aislado al main actor.

### Mock para previews y tests

```swift
import NetworkKitMocks

let mock = MockNetworkClient(json: #"[{ "id": "1", "title": "Hola" }]"#)
let mock = try MockNetworkClient(jsonFile: "posts")            // posts.json en Bundle.main
let mock = try MockNetworkClient(jsonFile: "posts", bundle: .module)
let mock = try MockNetworkClient(response: [Post.dummy])        // objeto Encodable
let mock = MockNetworkClient(error: .httpStatus(code: 500, data: Data()))

mock.receivedRequests  // [URLRequest] recibidas, en orden
```

## Tests

```sh
swift test
```
