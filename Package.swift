import PackageDescription

let package = Package(
    name: "SwiftMud",
    targets: [ ],
    dependencies: [
        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .Package(url: "https://github.com/vapor/sockets", Version(2,0,0, prereleaseIdentifiers: ["beta"]))
    ]
)

