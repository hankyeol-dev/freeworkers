// hankyeol-dev.

import Foundation
import Combine

final class LoungeHomeViewModel : ViewModelType {
   private let diContainer : DIContainer
   var store: Set<AnyCancellable> = .init()
   
   @Published var sheetConfig : SheetConfig?
   @Published var toastConfig : FWToast.FWToastType?
   @Published var profileImage : String = ""
   @Published var userId : String = ""
   @Published var userLoungeList : [LoungeListViewItem] = []
   
   enum SheetConfig : String, Identifiable {
      case displayCreateLounge
      
      var id : String { return String(describing: self.rawValue) }
   }
   
   enum Action {
      case getMe
      case createLounge
      case getLounges
      case pushToLounge(loungeId : String)
      case pushToProfile
   }
   
   init(diContainer : DIContainer) {
      self.diContainer = diContainer
   }
   
   func send(action: Action) {
      switch action {
      case .getMe:
         Task { await getMe() }
      case .getLounges:
         Task { await getLounges() }
      case .createLounge:
         sheetConfig = .displayCreateLounge
      case let .pushToLounge(loungeId):
         Task { await pushToLounge(loungeId : loungeId) }
      case .pushToProfile:
         diContainer.navigator.push(to: .profile(userId: userId))
      }
   }
}

extension LoungeHomeViewModel {
   private func getMe() async {
      await diContainer.services.userService.getMe()
         .receive(on : DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(errors) = errors {
               self?.toastConfig = .error(message: errors.errorMessage, duration: 1.5)
            }
         } receiveValue: { [weak self] item in
            if let profileImage = item.profileImage {
               self?.profileImage = profileImage
               self?.userId = item.userId
            }
         }
         .store(in: &store)
   }
   
   private func getLounges() async {
      await diContainer.services.workspaceService.getLounges()
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(errors) = errors {
               self?.toastConfig = .error(message: errors.errorMessage, duration: 1.5)
            }
         } receiveValue: { [weak self] viewItems in
            self?.userLoungeList = viewItems
         }
         .store(in: &store)
   }
   
   private func pushToLounge(loungeId : String) async {
      await MainActor.run { [weak self] in
         guard let self else { return }
         diContainer.navigator.push(to: .lounge(loungeId: loungeId))
      }
   }
}
