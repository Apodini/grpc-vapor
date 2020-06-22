// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "grpc-vapor",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "GRPCVapor", targets: ["GRPCVapor"]),
        .executable(name: "grpc-vapor-generator", targets: ["Generator"])
    ],
    dependencies: [
        .package(name: "vapor",
                 url: "https://github.com/vapor/vapor.git",
                 from: "4.0.0"),
        .package(name: "fluent",
                 url: "https://github.com/vapor/fluent.git",
                 from: "4.0.0"),
        .package(name: "fluent-sqlite-driver",
                 url: "https://github.com/vapor/fluent-sqlite-driver.git",
                 from: "4.0.0-rc.2"),
        .package(name: "GRPC",
                 url: "https://github.com/grpc/grpc-swift.git",
                 .exact("1.0.0-alpha.8")),
        .package(name: "SourceKitten",
                 url: "https://github.com/jpsim/SourceKitten.git",
                 .upToNextMajor(from: "0.27.0")),
        .package(name: "CLIKit",
                 url: "https://github.com/apparata/CLIKit.git",
                 from: "0.3.4"),
        .package(name: "SwiftProtobuf",
                 url: "https://github.com/apple/swift-protobuf",
                 from: "1.8.0"),
    ],
    targets: [
        .target(
            name: "GRPCVapor",
            dependencies: [
                .product(name: "GRPC", package: "GRPC"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Fluent", package: "fluent"),
            ]
        ),
        .target(
            name: "Generator",
            dependencies: [
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                .product(name: "SwiftProtobuf", package: "SwiftProtobuf"),
                .product(name: "CLIKit", package: "CLIKit")
            ]
        ),
        .testTarget(
            name: "GRPCVaporTests",
            dependencies: [
                .target(name: "GRPCVapor"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "SwiftProtobuf", package: "SwiftProtobuf"),
            ]
        ),
        .testTarget(
            name: "GeneratorTests",
            dependencies: [
                .target(name: "Generator"),
                .product(name: "SwiftProtobuf", package: "SwiftProtobuf"),
            ]
        ),
    ]
)
