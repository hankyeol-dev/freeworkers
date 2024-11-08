import SwiftUI
import SwiftData

import FreeworkersNetworkKit
import FreeworkersDBKit

@main
struct FreeworkersApp: App {
   @StateObject private var diContainer: DIContainer = .init(services: Services())
   
   var body: some Scene {
      WindowGroup {
         AuthEntryView(viewModel: .init(diContainer: diContainer))
            .environmentObject(diContainer)
      }
      .modelContainer(DatabaseService.shared.getContainer()) // DB
   }
}
