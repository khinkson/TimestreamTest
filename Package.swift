// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimestreamTest",
    platforms: [
        .macOS(.v11)
    ],
    products: [
         .executable(name: "TimestreamTest", targets: ["TimestreamTest"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from:"0.4.0")),
        .package(url: "https://github.com/swift-server/async-http-client.git", .upToNextMajor(from: "1.2.5")),
        .package(url: "https://github.com/soto-project/soto.git", .upToNextMajor(from: "5.5.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TimestreamTest",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-runtime"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "SotoTimestreamQuery", package: "soto")
            ]),
        .testTarget(
            name: "TimestreamTestTests",
            dependencies: ["TimestreamTest"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
