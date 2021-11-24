// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ReduxCore",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ReduxCore",
            type: .dynamic,
            targets: ["ReduxCore"])
    ],
    targets: [
        .target(
            name: "ReduxCore",
            path: "ReduxCore"
        )
    ]
)
