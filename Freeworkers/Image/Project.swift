// Image Cache Project

import ProjectDescription

let imagePlist: [String: Plist.Value] = [:]

let networkProject = Project(name: "FreeworkersImageKit",
                             organizationName: "teamhk",
                             targets: [
                              .target(
                                 name: "FreeworkersImageKit",
                                 destinations: .iOS,
                                 product: .framework,
                                 bundleId: "com.teamhk.freeworkers.imageKit",
                                 deploymentTargets: .iOS("17.0"),
                                 infoPlist: .extendingDefault(with: imagePlist),
                                 sources: ["Sources/**"],
                                 dependencies: [
                                    .project(target: "FreeworkersNetworkKit", path: "../Network")
                                 ])
                             ],
                             fileHeaderTemplate: .string("hankyeol-dev.")
)
