load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

swift_library(
    name = "Views",
    srcs = glob([
        "**/*.swift",
    ]),
    copts = ["-wmo"],
    module_name = "Views",
    visibility = ["//visibility:public"],
    deps = [
        "@Cleanse//:Cleanse",
        "@yoga//:YogaKit",
        "@yoga//:YogaKit_swift",
    ],
)
