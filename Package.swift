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
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc.3.5"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc.1"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-rc.1.1"),
        .package(url: "https://github.com/grpc/grpc-swift.git", .revision("58762ba")),
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
        .testTarget(
            name: "GRPCVaporTests",
            dependencies: ["GRPCVapor",
                           .product(name: "XCTVapor", package: "vapor")
            ]
        ),
    ]
)
