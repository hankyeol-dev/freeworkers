// hankyeol-dev.

import SwiftUI
import Combine

final class LoungeSettingViewModel : ViewModelType {
   private let diContainer : DIContainer
   private var loungeItem : LoungeViewItem
   var store: Set<AnyCancellable> = .init()
   
   @Published var isOwned : Bool = false
   @Published var sheetConfig : SheetConfig?
   @Published var toastConfig : FWToast.FWToastType?
   
   @Published var inviteEmail : String = ""
   @Published var validEmail : Bool = false
   
   @Published var loungeMemberListToggle : Bool = false
   @Published var loungeMembers : [UserCommonOutputType] = []
   
   enum Action {
      case didLoad
      case tapMenu(type : SheetConfig)
      case tapMemeberListToggle
      
      case validEmail
      case invite
   }
   
   enum SheetConfig : String, Identifiable {
      case invite
      case edit
      case changeOwnership
      case exit
      
      var id : String { return String(describing: self.rawValue) }
   }
   
   init(diContainer : DIContainer, loungeItem : LoungeViewItem) {
      print("setting viewModel init")
      self.diContainer = diContainer
      self.loungeItem = loungeItem
   }
   
   deinit {
      print("deinit")
   }
   
   func send(action: Action) {
      switch action {
      case .didLoad:
         Task { await fetchLoungeInfo() }
      case let .tapMenu(type):
         sheetConfig = type
      case .tapMemeberListToggle:
         loungeMemberListToggle.toggle()
      case .validEmail:
         validateInviteEmail()
      case .invite:
         Task { await handleInvite() }
      }
   }
}

extension LoungeSettingViewModel {
   func getLoungeName() -> String {
      return loungeItem.name
   }
   
   @MainActor
   private func fetchLoungeInfo() async {
      isOwned = await diContainer.services.validateService.validateIsLoungeOwner(loungeItem.ownerId)
      await fetchLoungeMember()
   }
   
   @MainActor
   private func fetchLoungeMember() async {
      let input: GetLoungeInputType = .init(loungeId: loungeItem.loungeId)
      await diContainer.services.workspaceService.getLoungeMembers(input: input)
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(error) = errors {
               self?.toastConfig = .error(message: error.errorMessage, duration: 1.5)
            }
         } receiveValue: { [weak self] members in
            self?.loungeMembers = members
         }
         .store(in: &store)
   }
 
   private func validateInviteEmail() {
      validEmail = diContainer.services.validateService.validateEmail(inviteEmail)
   }
   
   @MainActor
   private func handleInvite() async {
      let input: InviteLoungeInputType = .init(loungeId: loungeItem.loungeId,
                                               input: .init(email: inviteEmail))
      await diContainer.services.workspaceService.inviteLounge(input: input)
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(error) = errors {
               self?.toastConfig = .error(message: error.errorMessage, duration: 1.5)
            }
         } receiveValue: { [weak self] inviteSuccess in
            self?.sheetConfig = nil
         }
         .store(in: &store)
   }
}
