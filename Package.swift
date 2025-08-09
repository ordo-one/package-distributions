// swift-tools-version:6.1
import PackageDescription

let package:Package = .init(
    name: "package-distributions",
    products: [
        .library(name: "Random", targets: ["Random"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "Random",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics"),
            ],
            linkerSettings: [
                .linkedLibrary("m"),
            ],
        ),

        .testTarget(
            name: "RandomTests",
            dependencies: [
                .target(name: "Random"),
            ],
        ),
    ]
)
for target: Target in package.targets {
    {
        $0 = ($0 ?? []) + [
            .enableUpcomingFeature("ExistentialAny"),
        ]
    } (&target.swiftSettings)
}
