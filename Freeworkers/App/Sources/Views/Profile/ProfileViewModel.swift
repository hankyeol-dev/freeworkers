// hankyeol-dev.

import Foundation
import Combine

final class ProfileViewModel : ViewModelType {
   private let diContainer : DIContainer
   var store: Set<AnyCancellable> = .init()
   
   @Published var toastConfig : FWToast.FWToastType?
   @Published var profileViewItem : MeViewItem?
   @Published var isMe : Bool = false
   
   enum ProfileDestination : Hashable {
      case fillCoin
      case patchNickname
      case patchPhone
   }
   
   init(diContainer : DIContainer) {
      self.diContainer = diContainer
   }
   
   enum Action {
      case didLoad
      case validIsMe(userId : String)
      case tapBanner(_ destination : NavigationDestination)
      case dismiss
   }
   
   func send(action: Action) {
      switch action {
      case .didLoad:
         Task { await fetchProfile() }
      case let .validIsMe(userId):
         Task { await validIsMe(userId) }
      case let .tapBanner(destination):
         diContainer.navigator.push(to: destination)
      case .dismiss:
         diContainer.navigator.pop()
      }
   }
}

extension ProfileViewModel {
   @MainActor
   private func fetchProfile() async {
      await diContainer.services.userService.getMe()
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(error) = errors {
               self?.toastConfig = .error(message: error.errorMessage, duration: 1.0)
            }
         } receiveValue: { [weak self] viewItem in
            self?.profileViewItem = viewItem
            self?.send(action: .validIsMe(userId: viewItem.userId))
         }
         .store(in: &store)
   }
   
   @MainActor
   private func validIsMe(_ userId : String) async {
      await diContainer.services.validateService.validateIsMe(userId)
         .sink { [weak self] isMe in self?.isMe = isMe}
         .store(in: &store)
   }
}
