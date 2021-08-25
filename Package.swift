// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "JoyStickView",
  platforms: [.iOS(.v12)],
  products: [
    .library(
      name: "JoyStickView",
      targets: ["JoyStickView"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "JoyStickView",
      dependencies: [],
      exclude: ["Resources/Info.plist"]
    ),
    .testTarget(
      name: "JoyStickViewTests",
      dependencies: ["JoyStickView"],
      exclude: ["Info.plist"]
    )
  ]
)
