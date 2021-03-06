// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BunProKit",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BunProKit",
            targets: ["BunProKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        
        // Simple Swift wrapper for Keychain that works on iOS, watchOS, tvOS and macOS.
                .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "3.2.0")),

                // Advanced Operations in Swift
//                .package(path: "../ProcedureKit"),
                .package(url: "https://github.com/ProcedureKit/ProcedureKit.git", .upToNextMajor(from: "5.2.0")),

                // Convenient logging during development & release in Swift
                .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.7.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BunProKit",
            dependencies: [
                "KeychainAccess",
                .product(name: "ProcedureKitNetwork", package: "ProcedureKit"),
//                .product(name: "ProcedureKitNetwork"),
                "SwiftyBeaver"]),
        .testTarget(
            name: "BunProKitTests",
            dependencies: ["BunProKit"]),
    ]
)
