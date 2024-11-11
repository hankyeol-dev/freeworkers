import ProjectDescription

let networkPlist: [String: Plist.Value] = [:]

let networkProject = Project(name: "FreeworkersNetworkKit",
                             organizationName: "teamhk",
                             targets: [
                              .target(
                                 name: "FreeworkersNetworkKit",
                                 destinations: .iOS,
                                 product: .framework,
                                 bundleId: "com.teamhk.freeworkers.networkKit",
                                 deploymentTargets: .iOS("17.0"),
                                 infoPlist: .extendingDefault(with: networkPlist),
                                 sources: ["Sources/**"],
                                 dependencies: [
                                    .package(product: "SocketIO", type: ., condition: <#T##PlatformCondition?#>)
                                 ])
                             ],
                             fileHeaderTemplate: .string("hankyeol-dev.")
)
