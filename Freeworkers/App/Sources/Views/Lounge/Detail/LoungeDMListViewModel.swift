// hankyeol-dev.

import Foundation
import Combine

final class LoungeDMListViewModel : ViewModelType {
   private let diContainer : DIContainer
   private var loungeId : String
   var store: Set<AnyCancellable> = .init()
   
   @Published var loungeMembers : [UserCommonOutputType] = []
   @Published var loungeDMList : [DMListViewItemWithUnreads] = []
   
   @Published var toastConfig : FWToast.FWToastType?
   
   init(diContainer : DIContainer, loungeId : String) {
      self.diContainer = diContainer
      self.loungeId = loungeId
   }
   
   enum Action {
      case didLoad
      
      case pushToDM(user : UserCommonOutputType)
   }
   
   func send(action: Action) {
      switch action {
      case .didLoad:
         Task { await fetchLounge() }
         
      case let .pushToDM(user):
         diContainer.navigator.push(to: .dm(username: user.nickname,
                                            userId: user.user_id,
                                            loungeId: loungeId))
      }
   }
}

extension LoungeDMListViewModel {
   @MainActor
   private func fetchLounge() async {
      let getMemberInput : GetLoungeInputType = .init(loungeId: loungeId)
      await diContainer.services.workspaceService.getLoungeMembers(input: getMemberInput, exceptMe: true)
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(error) = errors {
               self?.toastConfig = .error(message: error.errorMessage, duration: 1.0)
            }
         } receiveValue: { [weak self] members in
            self?.loungeMembers = members
         }
         .store(in: &store)
      
      await diContainer.services.dmService.getLoungeDmsWithUnreads(
         loungeId: loungeId
      ) { list in
         DispatchQueue.main.async { [weak self] in
            self?.loungeDMList = list
         }
      }
   }
}
