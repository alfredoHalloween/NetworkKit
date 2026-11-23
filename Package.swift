// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    // Las funciones `async` no aisladas corren en el actor de quien las llama,
    // salvo que se marquen `@concurrent` (como `ResponseDecoder.decode`).
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "NetworkKit", targets: ["NetworkKit"]),
        .library(name: "NetworkKitMocks", targets: ["NetworkKitMocks"]),
    ],
    targets: [
        .target(
            name: "NetworkKit",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "NetworkKitMocks",
            dependencies: ["NetworkKit"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "NetworkKitMocksTests",
            dependencies: ["NetworkKit", "NetworkKitMocks"],
            resources: [.process("Resources")],
            swiftSettings: swiftSettings
        ),
    ]
)
