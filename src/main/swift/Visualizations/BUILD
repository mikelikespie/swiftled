load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

swift_library(
    name = "Visualizations",
    srcs = glob([
        "*.swift",
    ]),
    copts = ["-wmo"],
    module_name = "Visualizations",
    visibility = ["//visibility:public"],
    deps = [
        "//src/main/swift/OPC",
        "@Cleanse//:Cleanse",
        "@RxSwift//:RxSwift",
        "@libartnet//:artnet",
        "@yoga//:YogaKit",
        "@yoga//:YogaKit_swift",
    ],
)
