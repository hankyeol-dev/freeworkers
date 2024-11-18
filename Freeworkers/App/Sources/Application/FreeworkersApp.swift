import SwiftUI
import SwiftData

import FreeworkersDBKit

@main
struct FreeworkersApp: App {
   @StateObject private var diContainer : DIContainer = .init(services: Services())
   @StateObject private var envContainer : EnvironmentContainer = .init()
   
   var body: some Scene {
      WindowGroup {
         AuthEntryView(viewModel: .init(diContainer: diContainer))
            .environmentObject(diContainer)
            .environmentObject(envContainer)
      }
      .modelContainer(DatabaseService.shared.getContainer())
   }
}

