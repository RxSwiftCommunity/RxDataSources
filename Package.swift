// swift-tools-version:3.1

import PackageDescription

let package = Package(
  name: "RxDataSources",
  targets: [
    Target(name: "RxDataSources", dependencies: [.Target(name: "Differentiator")]),
    Target(name: "Differentiator"),
  ],
  dependencies: [
    .Package(url: "https://github.com/ReactiveX/RxSwift.git", majorVersion: 3),
  ]
)
