import PackageDescription

let package = Package(
    name: "Swiftled",
    targets: [
        Target(
            name: "OPC",
            dependencies: []),
        Target(
            name: "Visualizations",
            dependencies: [
                .Target(name: "OPC"),
                .Target(name: "libartnet"),
                .Target(name: "Cleanse"),
            ]),
        Target(
            name: "swiftled",
            dependencies: [
				.Target(name: "OPC"),
				.Target(name: "Visualizations"),
				.Target(name: "Cleanse"),
			]),
    ],
    dependencies: [
        .Package(url: "https://github.com/ReactiveX/RxSwift.git", majorVersion: 3)
    ]
)
