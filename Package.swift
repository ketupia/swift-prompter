// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "SwiftPrompter",
    platforms: [.macOS("27.0")],
    products: [.executable(name: "SwiftPrompter", targets: ["SwiftPrompter"])],
    targets: [
        .executableTarget(name: "SwiftPrompter", resources: [.copy("Resources/cmudict")]),
        .testTarget(name: "SwiftPrompterTests", dependencies: ["SwiftPrompter"])
    ]
)
