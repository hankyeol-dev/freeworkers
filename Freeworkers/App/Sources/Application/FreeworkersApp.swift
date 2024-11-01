import SwiftUI
import FreeworkersNetworkKit

@main
struct FreeworkersApp: App {
   @StateObject private var diContainer: DIContainer = .init(services: Services())
   
   var body: some Scene {
      WindowGroup {
         AuthenicationEntryView(viewModel: .init(diContainer: diContainer))
            .environmentObject(diContainer)
      }
   }
}
