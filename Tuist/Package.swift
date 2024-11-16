// swift-tools-version: 5.10.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
//   productTypes: ["MijickPopupView" : .framework]
)
#endif

let package = Package(
   name: "freeworkers",
   dependencies: [
//      .package(url: "https://github.com/Mijick/Popups.git", exact: "2.7.1")
   ]
)
