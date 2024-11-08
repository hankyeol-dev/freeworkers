// hankyeol-dev.

import SwiftUI
import Combine

struct AuthEntryView : View {
   @StateObject var viewModel: AuthEntryViewModel
   @EnvironmentObject var diContainer : DIContainer
   
   var body: some View {
      VStack {
         if viewModel.isLogined {
            if let loungeId = viewModel.latestEnteredLoungeId, !loungeId.isEmpty {
               LoungeView(viewModel: .init(diContainer: diContainer,
                                           loungeId: loungeId))
               .environmentObject(diContainer)
            } else {
               LoungeHomeView(viewModel: .init(diContainer: diContainer))
            }
         } else {
            LoginView(viewModel: .init(
               diContainer: diContainer,
               isLoginedHandler: { viewModel.send(action: .didLoad) }))            
         }
      }
      .task {
         viewModel.send(action: .didLoad)
      }
   }
}
