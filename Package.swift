// swift-tools-version:6.1
import PackageDescription

let package: Package = .init(
    name: "package-distributions",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "Random", targets: ["Random"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3"),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.4.0")),
    ],
    targets: [
        .target(
            name: "Random",
            dependencies: [
                .product(name: "RealModule", package: "swift-numerics")
            ],
            linkerSettings: [
                .linkedLibrary("m")
            ],
        ),

        .testTarget(
            name: "RandomTests",
            dependencies: [
                .target(name: "Random")
            ],
        ),

        .executableTarget(
            name: "RandomBenchmarks",
            dependencies: [
                .target(name: "Random"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/RandomBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        ),
    ]
)

for target: Target in package.targets {
    {
        $0 =
            ($0 ?? []) + [
                .enableUpcomingFeature("ExistentialAny")
            ]
    }(&target.swiftSettings)
}
