// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacTrainer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MacTrainer", targets: ["MacTrainer"])
    ],
    targets: [
        .executableTarget(
            name: "MacTrainer",
            path: "Sources/MacTrainer",
            resources: [
                .process("Resources/data")
            ]
        ),
        .testTarget(
            name: "MacTrainerTests",
            dependencies: ["MacTrainer"],
            path: "Tests/MacTrainerTests",
            resources: [
                .process("Fixtures")
            ]
        )
    ]
)
