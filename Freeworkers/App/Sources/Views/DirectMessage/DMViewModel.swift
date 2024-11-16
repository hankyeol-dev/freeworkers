// hankyeol-dev.

import Foundation
import Combine
import _PhotosUI_SwiftUI

import FreeworkersDBKit

final class DMViewModel : ViewModelType {
   private let diContainer : DIContainer
   private let loungeId : String
   private let userId : String // MARK: opponenetId
   private var roomId : String?
   
   var store: Set<AnyCancellable> = .init()
   
   @Published var chats : [Chat] = []
   @Published var chatText : String = ""
   
   @Published var photoSelection : [PhotosPickerItem] = []
   @Published var photoDatas : [(UIImage, Data)] = []
   
   @Published var photoViewerChat : Chat?
   @Published var photoViewerIndex : Int = 0
   @Published var displayPhotoViewer : Bool = false
   
   @Published var toastConfig : FWToast.FWToastType?
   
   init(
      diContainer : DIContainer,
      loungeId : String,
      userId : String
   ) {
      self.diContainer = diContainer
      self.loungeId = loungeId
      self.userId = userId
   }
   
   enum Action {
      case didLoad
      case didDisappear
      
      case displayPhotoViewer
      case tapChatImage(chatIndex : Int, photoIndex : Int)
      case deselectPhoto(photo : UIImage)
      
      case sendDM
   }
   
   func send(action: Action) {
      switch action {
      case .didLoad:
         Task { await fetchDMRoom() }
      case .didDisappear:
         Task { await diContainer.services.dmService.disconnect() }
        
      case .displayPhotoViewer:
         displayPhotoViewer.toggle()
      case let .tapChatImage(chatIndex, photoIndex):
         photoViewerChat = chats[chatIndex]
         photoViewerIndex = photoIndex
         send(action: .displayPhotoViewer)
      case let .deselectPhoto(photo):
         deselectPhoto(photo)
         
      case .sendDM:
         Task { await sendDM() }
      }
   }
}

extension DMViewModel {
   private func fetchDMRoom() async {
      await diContainer.services.dmService.getLoungeDms(loungeId: loungeId)
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { [weak self] list in
            guard let self else { return }
            // 1. lounge에 dm 목록을 조회한다.
            // 2. 해당 목록의 user > userId가 같은게 있는지 확인한다.
            let validRoom = validateIsAlreadyOpen(list)
            if !list.isEmpty, let room = validRoom {
               // 2-1. 있다면, 해당 방의 정보를 불러온다. => roomId 업데이트.
               roomId = room.roomId
               if let roomId, !roomId.isEmpty {
                  Task { [weak self] in await self?.fetchDMDatas() }
               }
            } else {
               // 2-2. 없거나 리스트가 비어있다면, 첫 채팅이 열리기 전까지 방을 생성하지 않는다.
               print("아직 비었어요~")
            }
         }
         .store(in: &store)
   }
   
   @MainActor
   private func fetchDMDatas() async {
      guard let roomId else { return }
      await diContainer.services.dmService.getDMDatas(loungeId: loungeId, roomId: roomId)
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { [weak self] chatDatas in
            guard let self else { return }
            let sort = SortDescriptor(\Chat.createdAt, order: .forward)
            chats = chatDatas.sorted(using: sort)
            
            var requestInput : GetChatsInputType
            
            if let last = chats.last?.createdAt {
               requestInput = .init(loungeId: loungeId, roomId: roomId, createdAt: last)
            } else {
               requestInput = .init(loungeId: loungeId, roomId: roomId, createdAt: nil)
            }
            
            Task { [weak self] in await self?.fetchDms(requestInput) }
         }
         .store(in: &store)
   }
   
   @MainActor
   private func fetchDms(_ requestInput : GetChatsInputType) async {
      await diContainer.services.dmService.getDms(input: requestInput)
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors { print(error.errorMessage) }
         } receiveValue: { chats in
            Task { [weak self] in
               if !chats.isEmpty {
                  for chat in chats {
                     // DB에 넣어주는 작업!
                     await self?.saveMyChat(chat.toSaveRequest)
                  }
                  
                  await self?.connect()
               }
            }
         }
         .store(in: &store)
   }
   
   private func deselectPhoto(_ photo : UIImage) {
      guard let target = photoDatas.firstIndex(where: { $0.0 == photo }) else { return }
      photoSelection.remove(at: target)
      photoDatas.remove(at: target)
   }
}

extension DMViewModel {
   @MainActor
   private func sendDM() async {
      if validateIsCanSend() {
         // 1. roomId가 비어있다면, 처음 보내는 DM이기 때문에 방 생성부터 해준다.
         if roomId == nil {
            let input : OpenDMInputType = .init(loungeId: loungeId, input: .init(opponent_id: userId))
            await diContainer.services.dmService.openDms(input: input)
               .receive(on: DispatchQueue.main)
               .sink { errors in
                  if case let .failure(error) = errors {
                     print(error.errorMessage)
                  }
               } receiveValue: { [weak self] item in
                  self?.roomId = item.roomId
                  
                  // 2. send logic
                  Task { [weak self] in
                     await self?.connect()
                     await self?.sendDM()
                  }
               }
               .store(in: &store)
         } else {
            guard let roomId else { return }
            let input : ChatInputType = .init(loungeId: loungeId,
                                              roomId: roomId,
                                              chatInput: .init(content: .init(content: chatText),
                                                               files: photoDatas.map({ $0.1 })))
            await diContainer.services.dmService.sendDM(input: input)
               .receive(on: DispatchQueue.main)
               .sink { [weak self] errors in
                  if case let .failure(error) = errors {
                     self?.toastConfig = .error(message: error.errorMessage, duration: 1.0)
                  }
               } receiveValue: { chat in
                  Task { [weak self] in
                     self?.validateResetView()
                     await self?.saveMyChat(chat.toSaveRequest)
                  }
               }
               .store(in: &store)
         }
      }
   }
   
   @MainActor
   private func saveMyChat(_ chat : ChatSaveRequestType) async {
      if validateIsNotSaved(chat.chatId) {
         let saved = await diContainer.services.dmService.saveDM(loungeId: loungeId,
                                                                 chatRequest: chat)
         chats.append(saved)
         validateResetView()
      }
   }
   
   @MainActor
   private func saveReceivedChat(_ chat : ChatSaveRequestType) async {
      if let saved = await diContainer.services.dmService.saveReceivedDM(
         loungeId: loungeId,
         chatRequest: chat
      ) {
         chats.append(saved)
         validateResetView()
      }
   }
}

extension DMViewModel {
   private func validateIsAlreadyOpen(_ dmList : [LoungeDMViewItem]) -> LoungeDMViewItem? {
      return dmList.filter({ $0.opponent.user_id == userId }).first
   }
   
   private func validateIsCanSend() -> Bool {
      return !chatText.isEmpty || !photoDatas.isEmpty
   }
   
   private func validateIsNotSaved(_ chatId : String) -> Bool {
      return chats.filter({ $0.id == chatId }).count == 0
   }
   
   private func validateResetView() {
      if !chatText.isEmpty { chatText = "" }
      if !photoDatas.isEmpty { photoDatas = [] }
      if !photoSelection.isEmpty { photoSelection = [] }
   }
}

extension DMViewModel {
   private func connect() async {
      if let roomId, !roomId.isEmpty {
         await diContainer.services.dmService.connect(roomId: roomId) { receivedChat in
            // decoding and save chat logic here
            do {
               let received = try JSONDecoder().decode(DMChatOutputType.self, from: receivedChat)
               Task { [weak self] in await self?.saveReceivedChat(received.toSaveRequest) }
            } catch {
               print("dm socket error: ", error)
            }
         }
      }
   }
}
