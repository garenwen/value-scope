// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ValueScope",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ValueScope", targets: ["ValueScope"]),
    ],
    targets: [
        .target(name: "ValueScope", path: "ValueScope"),
    ]
)
