import SwiftUI
import FreeworkersNetworkKit

@main
struct FreeworkersApp: App {
   var body: some Scene {
      WindowGroup {
         TestView()
      }
   }
}

struct TestView: View {
   var body: some View {
      Text("hello world")
         .task {
            let networkRepository = NetworkRepository()
            networkRepository.sayhi()
         }
   }
}
