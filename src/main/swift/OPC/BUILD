load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

swift_library(
    name = "OPC",
    srcs = glob([
        "*.swift",
    ]),
    module_name = "OPC",
    visibility = ["//visibility:public"],
    deps = [
        "@RxSwift//:RxSwift",
    ],
)
