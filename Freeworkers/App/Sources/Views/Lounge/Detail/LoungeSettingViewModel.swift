// hankyeol-dev.

import SwiftUI
import UIKit
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
   
   @Published var loungeName : String = ""
   @Published var loungeDescription : String = ""
   @Published var loungeImage : String = ""
   @Published var changedImage : (UIImage?, Data?)?
   
   @Published var selectedMember : UserCommonOutputType?
   @Published var displayLeavePopup : Bool = false
   @Published var displayLeaveErrorMessage : String?
   
   @Published var loungeMemberListToggle : Bool = false
   @Published var loungeMembers : [UserCommonOutputType] = []
   
   enum Action {
      case didLoad
      case tapMenu(type : SheetConfig)
      case tapMemeberListToggle
      case tapMenuReset(type : SheetConfig)
      
      case validEmail
      case invite
      case edit
      case setImage(image : UIImage, imageData : Data)
      case setOwner(member : UserCommonOutputType)
      case changeOwner
      case exit
      
      // MARK: navigation
      case pushToProfile(userId : String)
   }
   
   enum SheetConfig : String, Identifiable {
      case invite
      case edit
      case changeOwnership
      
      var id : String { return String(describing: self.rawValue) }
   }
   
   init(diContainer : DIContainer, loungeItem : LoungeViewItem) {
      self.diContainer = diContainer
      self.loungeItem = loungeItem
      
      loungeName = loungeItem.name
      loungeDescription = loungeItem.description ?? ""
      loungeImage = loungeItem.coverImage
   }
   
   func send(action: Action) {
      switch action {
      case .didLoad:
         Task { await fetchLoungeInfo() }
      case let .tapMenu(type):
         sheetConfig = type
      case .tapMemeberListToggle:
         loungeMemberListToggle.toggle()
      case let .tapMenuReset(type):
         tapMenuInfoReset(type)
         
      case .validEmail:
         validateInviteEmail()
      case .invite:
         Task { await handleInvite() }
      case .edit:
         Task { await editLounge() }
      case let .setImage(image, imageData):
         DispatchQueue.main.async { [weak self] in self?.changedImage = (image, imageData) }
      case let .setOwner(member):
         selectedMember = member
      case .changeOwner:
         Task { await changeLoungeOwner() }
      case .exit:
         Task { await exitLounge() }
         
      case let .pushToProfile(userId):
         diContainer.navigator.push(to: .profile(userId: userId))
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
      await diContainer.services.workspaceService.getLoungeMembers(input: input, exceptMe: true)
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
}

extension LoungeSettingViewModel {
   private func tapMenuInfoReset(_ type : SheetConfig) {
      switch type {
      case .invite:
         inviteEmail = ""
      case .edit:
         loungeName = loungeItem.name
         loungeDescription = loungeItem.description ?? ""
         loungeImage = loungeItem.coverImage
         changedImage = nil
      case .changeOwnership:
         selectedMember = nil
      }
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
            self?.inviteEmail = ""
         }
         .store(in: &store)
   }
}

extension LoungeSettingViewModel {
   private func validateCanEdit() -> Bool {
      return loungeName != loungeItem.name || changedImage != nil
   }
   
   @MainActor
   private func editLounge() async {
      if validateCanEdit() {
         var input : EditLoungeInputType = .init(loungeId: loungeItem.loungeId,
                                                 content: .init(name: "", description: ""),
                                                 file: .init(image: nil))
         
         if let imageData = changedImage, let image = imageData.1 {
            input.file.image = image
         }
         if !loungeName.isEmpty { input.content.name = loungeName }
         if !loungeDescription.isEmpty { input.content.description = loungeDescription }
         
         await diContainer.services.workspaceService.editLounge(input: input)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errors in
               if case let .failure(error) = errors {
                  self?.toastConfig = .error(message: error.errorMessage, duration: 1.0)
               }
            } receiveValue: { [weak self] item in
               self?.loungeItem = item
               self?.toastConfig = .success(message: appTexts.LOUNGE_EDIT_SUCCESS, duration: 1.0)
               self?.sheetConfig = nil
            }
            .store(in: &store)
      } else {
         toastConfig = .error(message: errorText.ERROR_NO_CHANGE, duration: 1.0)
      }
   }
   
   @MainActor
   private func changeLoungeOwner() async {
      guard let changedOwner = selectedMember else { return }
      
      let input : ChangeOwnerInputType = .init(loungeId: loungeItem.loungeId,
                                               input: .init(owner_id: changedOwner.user_id))
      await diContainer.services.workspaceService.changeLoungeOwner(input: input)
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(error) = errors {
               self?.toastConfig = .error(message: error.errorMessage, duration: 1.0)
            }
         } receiveValue: { [weak self] item in
            self?.loungeItem = item
            self?.isOwned = false
            self?.toastConfig = .success(message: appTexts.LOUNGE_CHANGE_OWNER_SUCCESS, duration: 1.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               self?.selectedMember = nil
               self?.sheetConfig = nil
            }
         }
         .store(in: &store)
   }
   
   @MainActor
   private func exitLounge() async {
      await diContainer.services.workspaceService.exitLounge(loungeId: loungeItem.loungeId)
         .receive(on: DispatchQueue.main)
         .sink { [weak self] errors in
            if case let .failure(error) = errors {
               self?.displayLeavePopup = false
               self?.displayLeaveErrorMessage = error.errorMessage
            }
         } receiveValue: { [weak self] _ in
            self?.displayLeavePopup = false
            self?.diContainer.navigator.popToRoot()
         }
         .store(in: &store)
   }
}
