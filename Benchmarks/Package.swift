// swift-tools-version:6.1
import PackageDescription

let package: Package = .init(
    name: "benchmarks",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.4.0")),
    ],
    targets: [
        .executableTarget(
            name: "RandomBenchmarks",
            dependencies: [
                .product(name: "Random", package: "package-distributions"),
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
