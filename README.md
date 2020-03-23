# gRPC Vapor

gRPC Vapor is a Vapor middleware framework that enables Vapor servers to support, route, encode and decode  [gRPC](https://grpc.io) requests.

This framework is designed to work together with the [GRPCVaporGenerator]() which analyzes the declared gRPC services and messages and then generates the necessary supporting code to route requests, provide encoding and decoding support and provide a proto interface definition file.

This framework is like the 1.0 version of [grpc-swift](https://github.com/grpc/grpc-swift) build ontop of [SwiftNIO](https://github.com/apple/swift-nio) instead of the common [C-Core](https://github.com/grpc/grpc) for most implementations.
This is due to usage of the [Vapor](https://github.com/vapor/vapor) as its networking component.
The encoding and decoding of the gRPC messages is realized using the [SwiftProtobuf](https://github.com/apple/swift-protobuf) framework.

## Supported Systems
This framework works with Vapor version 4.0 or higher and requires the Swift version to be 5.2 or higher.

## Basic Structure
The interface of this framework primarly consists of three main components that are needed to declare and integrate gRPC services in an existing Vapor application: 
- A `GRPCMiddleware` that implements Vapors `Middleware` protocol and can therefore be added to a Vapor application.
- A `GRPCService` protocol that declares a structure or class as a gRPC service and provides a routing method for remote procedure calls.
- A `GRPCModel` protocol that declares a structure or class as a gRPC message that can be used as an input or output of remote procedure calls.

Additionally:

Using call handlers
GRPCMessage
GRPCRequest
GRPCStream


## Usage
Instructions to integrate 


## License
??

## Contributing
If you want to contribute your own ideas and changes to feel free to create a github issue or contact me directly via e-mail [michael.schlicker@tum.de](mailto:michael.schlicker@tum.de).
