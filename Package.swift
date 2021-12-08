// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "segmentcli",
    platforms: [
            .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
        .package(url: "https://github.com/dominicegginton/Spinner", from: "1.1.4"),
        .package(url: "https://github.com/mtynior/ColorizeSwift.git", from: "1.5.0"),
        .package(url: "https://github.com/segmentio/analytics-swift.git", branch: "bsneed/cli_additions"),
        .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.6.1"),
        .package(url: "https://github.com/AlwaysRightInstitute/Mustache", from: "1.0.0"),
        .package(url: "https://github.com/antitypical/Result.git", from: "5.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "segmentcli",
            dependencies: ["SwiftCLI",
                           "Spinner",
                           "ColorizeSwift",
                           "SwiftCSV",
                           "Result",
                           .product(name: "mustache", package: "Mustache"),
                           .product(name: "Segment", package: "analytics-swift")]),
        .testTarget(
            name: "segmentcliTests",
            dependencies: ["segmentcli"]),
    ]
)
