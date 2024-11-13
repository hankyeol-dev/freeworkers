import SwiftUI
import SwiftData

import FreeworkersDBKit
import MijickPopupView

@main
struct FreeworkersApp: App {
   @StateObject private var diContainer: DIContainer = .init(services: Services())
   
   var body: some Scene {
      WindowGroup {
         AuthEntryView(viewModel: .init(diContainer: diContainer))
            .environmentObject(diContainer)
            .implementPopupView(config: configPopup)
      }
      .modelContainer(DatabaseService.shared.getContainer()) // DB
   }
}

extension FreeworkersApp {
   func configPopup(_ config : GlobalConfig) -> GlobalConfig {
      config.centre { $0.tapOutsideToDismiss(true) }
   }
}
