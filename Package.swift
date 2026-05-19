// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudeHebrew",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "ClaudeHebrew",
            path: "Sources/ClaudeHebrew"
        )
    ]
)
