// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "RxDataSources",
  platforms: [
    .iOS(.v8), .tvOS(.v9)
  ],
  products: [
    .library(name: "RxDataSources", targets: ["RxDataSources"]),
    .library(name: "Differentiator", targets: ["Differentiator"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "4.5.0")),
  ],
  targets: [
    .target(name: "RxDataSources", dependencies: ["Differentiator", "RxSwift", "RxCocoa"]),
    .target(name: "Differentiator"),
    .testTarget(name: "RxDataSourcesTests", dependencies: ["RxDataSources"]),
  ],
  swiftLanguageVersions: [.v4_2, .v5]
)
