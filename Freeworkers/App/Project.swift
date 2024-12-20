import Foundation
import ProjectDescription

let appInfoPlist: [String: Plist.Value] = [
   "UILaunchScreen": [
       "UIColorName": "",
       "UIImageName": "",
   ],
   "App Transport Security Settings" : [
      "Allow Arbitrary Loads" : "YES"
   ]
]

let appProject = Project(name: "APP",
                         organizationName: "teamhk",
                         targets: [
                           .target(
                              name: "FreeworkersApp",
                              destinations: .iOS,
                              product: .app,
                              bundleId: "com.teamhk.freeworkers",
                              deploymentTargets: .iOS("17.0"),
                              infoPlist: .extendingDefault(with: appInfoPlist),
                              sources: ["Sources/**"],
                              resources: ["Resources/**"],
                              dependencies: [
                                 .project(target: "FreeworkersNetworkKit", path: "../Network"),
                                 .project(target: "FreeworkersDBKit", path: "../Database"),
                                 .project(target: "FreeworkersImageKit", path: "../Image"),
                                 .external(name: "iamport-ios")
                              ])
                         ],
                         fileHeaderTemplate: .string("hankyeol-dev.")
)
