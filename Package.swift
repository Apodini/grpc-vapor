// swift-tools-version:5.1
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
            targets: ["grpc-vapor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/michaelschlicker/vapor-grpc.git", .revision("569a1828")),
        .package(url: "https://github.com/michaelschlicker/fluent-grpc.git", .revision("b4feed4")),
        .package(url: "https://github.com/vapor/fluent-kit.git", .revision("2535037")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", .revision("d2bb65b")),
        .package(url: "https://github.com/grpc/grpc-swift.git", .revision("58762ba")),
        .package(url: "https://github.com/vapor/sql-kit", .revision("f0e0029")),
        .package(url: "https://github.com/vapor/sqlite-kit", .revision("f25b68e")),
        .package(url: "https://github.com/vapor/routing-kit", .revision("39f0710"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "grpc-vapor",
            dependencies: ["FluentSQLiteDriver", "Vapor", "GRPC", "Fluent"]),
        .testTarget(
            name: "grpc-vaporTests",
            dependencies: ["grpc-vapor"]),
    ]
)
