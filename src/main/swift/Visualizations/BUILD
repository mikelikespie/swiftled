load("@build_bazel_rules_apple//apple:swift.bzl", "swift_library")

swift_library(
    name = "Visualizations",
    srcs = glob([
        "*.swift",
    ]),
    deps = [
        "@RxSwift//:RxSwift",
        "@Cleanse//:Cleanse",
        "@libartnet//:artnet",
        "//src/main/swift/OPC",
    ],
    module_name = "Visualizations",
    visibility = ["//visibility:public"],
    copts = ['-wmo']
    
    
)

