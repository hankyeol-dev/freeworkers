// swift-tools-version: 5.10.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
   productTypes: ["SocketIO": .framework]
)
#endif

let package = Package(
   name: "freeworkers",
   dependencies: [
      .package(url: "https://github.com/socketio/socket.io-client-swift.git", from: "16.1.1"),
   ]
)
