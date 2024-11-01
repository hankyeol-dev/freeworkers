// hankyeol-dev.

import SwiftUI
import Combine

struct AuthenicationEntryView : View {
   @StateObject var viewModel: ViewModel
   @EnvironmentObject var diContainer : DIContainer
   
   var body: some View {
      VStack {
         switch viewModel.isLogined {
         case true:
            Text("\(viewModel.me?.nickname ?? "유저 닉네임 불러오기 실패!")")
               .task {
                  viewModel.send(action: .getMe)
               }
         case false:
            LoginView(viewModel: .init(
               diContainer: diContainer,
               isLoginedHandler: { viewModel.send(action: .validIsLogined) }))
         }
      }
      .task {
         viewModel.send(action: .validIsLogined)
      }
   }
}

extension AuthenicationEntryView {
   final class ViewModel : ViewModelType {
      private let diContainer: DIContainer
      var store: Set<AnyCancellable> = .init()
      
      @Published var isLogined : Bool = false
      @Published var me : MeViewItem?
      
      enum Action {
         case validIsLogined
         case getMe
      }
      
      init(diContainer : DIContainer) {
         self.diContainer = diContainer
      }
      
      func send(action: Action) {
         switch action {
         case .validIsLogined:
            Task {
               await validIsLogined()
            }
         case .getMe:
            Task {
               await diContainer.services.userService.getMe()
                  .receive(on: DispatchQueue.main)
                  .sink { error in
                     if case let .failure(errorMessage) = error {
                        print(errorMessage.errorMessage)
                     }
                  } receiveValue: { [weak self] viewItem in
                     dump(viewItem)
                     self?.me = viewItem
                  }
                  .store(in : &store)
            }
         }
      }
   }
}

extension AuthenicationEntryView.ViewModel {
   func validIsLogined() async {
      await diContainer.services.authService.validIsLogined()
         .receive(on: DispatchQueue.main)
         .sink { [weak self] loginState in
            guard let self else { return }
            isLogined = loginState
         }
         .store(in: &store)
   }
}
