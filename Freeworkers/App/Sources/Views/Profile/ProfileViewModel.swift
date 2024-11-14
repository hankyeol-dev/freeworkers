// hankyeol-dev.

import Foundation
import Combine

final class ProfileViewModel : ViewModelType {
   private let diContainer : DIContainer
   private let userId : String
   
   var store: Set<AnyCancellable> = .init()
   
   @Published var toastConfig : FWToast.FWToastType?
   @Published var profileViewItem : MeViewItem?
   @Published var anotherProfileViewItem : AnotherViewItem?
   @Published var isMe : Bool = false
   
   enum ProfileDestination : Hashable {
      case fillCoin
      case patchNickname
      case patchPhone
   }
   
   init(diContainer : DIContainer, userId : String) {
      self.diContainer = diContainer
      self.userId = userId
   }
   
   enum Action {
      case didLoad
      case tapBanner(_ destination : NavigationDestination)
      case dismiss
   }
   
   func send(action: Action) {
      switch action {
      case .didLoad:
         Task { await fetchProfile() }
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
      await diContainer.services.validateService.validateIsMe(userId)
         .receive(on: DispatchQueue.main)
         .sink { [weak self] isMe in
            self?.isMe = isMe
            if isMe {
               Task { [weak self] in await self?.fetchMe() }
            } else {
               // 다른 유저 프로필 조회
               Task { [weak self] in await self?.fetchAnother() }
            }
         }
         .store(in: &store)
   }
   
   @MainActor
   private func fetchMe() async {
      await diContainer.services.userService.getMe()
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(error) = errors {
               self?.toastConfig = .error(message: error.errorMessage, duration: 1.0)
            }
         } receiveValue: { [weak self] viewItem in
            self?.profileViewItem = viewItem
         }
         .store(in: &store)
   }
   
   @MainActor
   private func fetchAnother() async {
      await diContainer.services.userService.getAnother(userId)
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(error) = errors {
               self?.toastConfig = .error(message: error.errorMessage, duration: 1.0)
            }
         } receiveValue: { [weak self] viewItem in
            self?.anotherProfileViewItem = viewItem
         }
         .store(in: &store)
   }
}
