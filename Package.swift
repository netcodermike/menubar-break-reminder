// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "BreakReminder", platforms: [.macOS(.v13)], products: [.executable(name: "BreakReminder", targets: ["BreakReminder"])], targets: [.executableTarget(name: "BreakReminder")])
