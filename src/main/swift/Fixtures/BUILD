load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

swift_library(
    name = "Fixtures",
    srcs = glob([
        "**/*.swift",
    ]),
    copts = ["-wmo"],
    module_name = "Fixtures",
    visibility = ["//visibility:public"],
    deps = [
        "@Cleanse//:Cleanse",
        "@RxSwift//:RxSwift",
        "@yoga//:YogaKit",
        "@yoga//:YogaKit_swift",
    ],
)
