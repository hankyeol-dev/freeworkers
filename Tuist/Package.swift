// swift-tools-version: 5.10.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
   productTypes: ["Kingfisher": .framework]
)
#endif

let package = Package(
   name: "freeworkers",
   dependencies: [
      .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.1.0")
   ]
)
