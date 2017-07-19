load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")

swift_library(
    name = "SwiftledMobile_lib",
    srcs = glob([
        "*.swift",
    ]),
    deps = [
        "//src/main/swift/OPC",
        "//src/main/swift/Visualizations",
        "@RxSwift//:RxSwift",
    ],
)

objc_library(
    name = "SwiftledMobule_assets",
    asset_catalogs = glob(["Assets.xcassets/**"]),
    storyboards = glob(["**/*.storyboard"]),
)

# Links code from "deps" into an executable, collects and compiles resources
# from "deps" and places them with the executable in an .app bundle, and then
# outputs an .ipa with the bundle in its Payload directory.
ios_application(
    name = "SwiftledMobile",
    bundle_id = "org.lolrus.swiftled",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [":Info.plist"],
    launch_storyboard = "Base.lproj/LaunchScreen.storyboard",
    minimum_os_version = "10.0",
    deps = [
        ":SwiftledMobile_lib",
    ],
)
