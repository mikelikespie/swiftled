load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")

swift_library(
    name = "Swiftlights_lib",
    srcs = glob([
        "*.swift",
    ]),
    module_name = "Swiftlights",
    copts = ["-wmo"],
    deps = [
        "//src/main/swift/Fixtures",
		"//src/main/swift/Views",
        "//src/main/swift/Artnet",
        "@RxSwift//:RxSwift",
    ],
)

objc_library(
    name = "Swiftlights_assets",
    asset_catalogs = glob(["Assets.xcassets/**"]),
    storyboards = glob(["**/*.storyboard"]),
)

# Links code from "deps" into an executable, collects and compiles resources
# from "deps" and places them with the executable in an .app bundle, and then
# outputs an .ipa with the bundle in its Payload directory.
ios_application(
    name = "Swiftlights",
    bundle_id = "org.lolrus.swiftlights",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [":Info.plist"],
    launch_storyboard = "Base.lproj/LaunchScreen.storyboard",
    minimum_os_version = "10.0",
    deps = [
        ":Swiftlights_lib",
        ":Swiftlights_assets",
    ],
)
