import PackageDescription

let package = Package(
    name: "Swiftled",
    targets: [
        Target(
            name: "OPC",
            dependencies: [.Target(name: "RxSwift")]),
        Target(
            name: "Visualizations",
            dependencies: [
                .Target(name: "OPC"),
                .Target(name: "Cleanse"),
            ]),
        Target(
            name: "swiftled",
            dependencies: [
				.Target(name: "OPC"),
				.Target(name: "Visualizations"),
				.Target(name: "Cleanse"),
			]),
    ]
)
