// hankyeol-dev.

import Foundation
import Combine

final class AuthEntryViewModel : ViewModelType {
   private let diContainer : DIContainer
   var store: Set<AnyCancellable> = .init()
   
   @Published var isLogined : Bool = false
   @Published var latestEnteredLoungeId : String? = UserDefaults.standard.string(
      forKey: AppEnvironment.UserDefaultsKeys.latestEnteredChannelId.rawValue)
   
   enum Action {
      case didLoad
   }
   
   init(diContainer : DIContainer) {
      self.diContainer = diContainer
   }
   
   func send(action: Action) {
      switch action {
      case .didLoad:
         Task {
            await validIsLogined()
         }
      }
   }
}

extension AuthEntryViewModel {
   func validIsLogined() async {
      await diContainer.services.authService.validIsLogined()
         .receive(on: DispatchQueue.main)
         .sink { [weak self] loginState in
            guard let self else { return }
            isLogined = loginState
         }
         .store(in: &store)
   }
   
   // TODO: 어떻게 활용할지 고민하기
   func getLatestEnteredChannel() {
      diContainer.services.authService.getLatestEnteredChannel()
         .receive(on: DispatchQueue.main)
         .sink(receiveValue: { [weak self] latestChannel in
            self?.latestEnteredLoungeId = latestChannel
         })
         .store(in: &store)
   }
}
