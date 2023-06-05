// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "CPFWaterfallFlowLayout",
    products: [
        .library(
            name: "CPFWaterfallFlowLayout",
            targets: ["CPFWaterfallFlowLayout"]),
        .library(
            name: "CPFWaterfallFlowLayout-Dynamic",
            type: .dynamic,
            targets: ["CPFWaterfallFlowLayout"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Loadar/CPFChain.git", from: Version(stringLiteral: "2.2.3")),
    ],
    targets: [
        .target(
            name: "CPFWaterfallFlowLayout",
            dependencies: ["CPFChain"]),
    ]
)
