import ProjectDescription

let databasePlist: [String: Plist.Value] = [:]

let databaseProject = Project(name: "FreeworkersDBKit",
                              organizationName: "teamhk",
                              targets: [
                                 .target(
                                    name: "FreeworkersDBKit",
                                    destinations: .iOS,
                                    product: .framework,
                                    bundleId: "com.teamhk.freeworkers.dbKit",
                                    deploymentTargets: .iOS("17.0"),
                                    infoPlist: .extendingDefault(with: databasePlist),
                                    sources: ["Sources/**"],
                                    dependencies: [])
                              ],
                              fileHeaderTemplate: .string("hankyeol-dev.")
)
