load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

swift_library(
    name = "Artnet",
    srcs = glob([
        "**/*.swift",
    ]),
    copts = ["-wmo"],
    module_name = "Artnet",
    visibility = ["//visibility:public"],
    deps = [
        "@libartnet//:artnet",
        "@Cleanse//:Cleanse",
    ],
)
