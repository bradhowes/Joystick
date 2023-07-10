// swift-tools-version:5.7

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

#if swift(>=5.6)
// Add the documentation compiler plugin if possible
package.dependencies.append(
  .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
)
#endif
