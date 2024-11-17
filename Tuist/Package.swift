// swift-tools-version: 5.10.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
   productTypes: ["iamport-ios" : .framework, "SocketIO" : .framework]
)
#endif

let package = Package(
   name: "freeworkers",
   dependencies: [
      .package(url: "https://github.com/iamport/iamport-ios.git", exact: "1.4.6"),
      .package(url: "https://github.com/socketio/socket.io-client-swift.git", exact: "16.1.1")
   ]
)
