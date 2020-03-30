// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "grpc-vapor",
    platforms: [
       .macOS(.v10_15)
    ],

    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GRPCVapor",
            targets: ["GRPCVapor"]),
        .executable(name: "grpc-vapor-generator", targets: ["Generator"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc.3.5"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc.1"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-rc.1.1"),
        .package(url: "https://github.com/grpc/grpc-swift.git", .exact("1.0.0-alpha.8")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMajor(from: "0.27.0")),
        .package(url: "https://github.com/apparata/CLIKit.git", from: "0.3.4"),
        .package(url: "https://github.com/apple/swift-protobuf", from: "1.8.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GRPCVapor",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Fluent", package: "fluent"),
            ]
        ),
        .target(
            name: "Generator",
            dependencies: [
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "CLIKit", package: "CLIKit")
            ]
        ),
        .testTarget(
            name: "GRPCVaporTests",
            dependencies: ["GRPCVapor",
                           .product(name: "XCTVapor", package: "vapor")
            ]
        ),
        .testTarget(
            name: "GeneratorTests",
            dependencies: ["Generator"]
        ),
    ]
)
