// hankyeol-dev.

import Foundation
import SwiftData
import Combine

import FreeworkersDBKit

final class ChannelViewModel : ViewModelType {
   private let diContainer : DIContainer
   private let channelId : String
   private let loungeId : String
   
   var store: Set<AnyCancellable> = .init()
   
   @Published var chats : [Chat] = []
   @Published var chatText : String = ""
   @Published var isDisplayChannelSetting : Bool = false
   
   init(diContainer : DIContainer, channelId : String, lougneId : String) {
      self.diContainer = diContainer
      self.channelId = channelId
      self.loungeId = lougneId
   }
   
   enum Action {
      case enterChannel
      case fetchChannelData
      case sendChannelChat
      
      // Touch
      case moveOutFromChannel
      case channelSettingButtonTapped
   }
   
   func send(action: Action) {
      switch action {
      case .enterChannel:
         Task { await enterChannel() }
      case .fetchChannelData:
         Task { await fetchChannelData() }
      case .sendChannelChat:
         Task { await sendChannelChat() }
      case .moveOutFromChannel:
         Task { await disconnectSocket() }
      case .channelSettingButtonTapped:
         pushToSettingView()
      }
   }
}

// MARK: Fetch Chat, View Info
extension ChannelViewModel {
   func getChannelId() -> String {
      return channelId
   }
   
   private func enterChannel() async {
      // 1. database에서 저장된 데이터를 먼저 가지고 온다.
      await fetchChannelData()
      var requestInput : GetChatsInputType
      
      // 2. database에서 불러온 데이터 중 마지막 데이터의 created_at 값으로 서버에 조회한다.
      if let latestChatDate = chats.last?.createdAt {
         requestInput = .init(loungeId: loungeId, roomId: channelId, createdAt: latestChatDate)
      } else {
         // 3. 앱을 처음 설치했을 경우, 서버에서  이전 데이터를 모두 불러온다? => X
         // - 생각해보면, 카카오톡도 아카이브를 하지 않는 이상 방 나왔다가 다시 들어가면 처음부터 시작임
         // - 근데 또 생각해보면, 해당 채널에 참여하려고 하는 사람일수도?
         // => 불러오는게 맞는 듯.
         requestInput = .init(loungeId: loungeId, roomId: channelId, createdAt: nil)
      }
      
      await fetchChannelChats(requestInput)
   }
   
   private func fetchChannelChats(_ requestInput : GetChatsInputType) async {
      await diContainer.services.channelService.getChannelChats(input: requestInput)
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { chats in
            Task { [weak self] in
               // 2-1. 업데이트 할 내용이 있다면
               // - 1. db에 먼저 저장
               // - 2. viewModel chats 배열에 반영
               for chat in chats {
                  guard let self else { return }
                  await saveMyChat(for: chat.toSaveRequest)
               }
               // 2-2. socket 연결
               guard let self else { return }
               await connectSocket()
            }
         }
         .store(in: &store)
   }
   
   private func fetchChannelData() async {
      await diContainer.services.channelService.getChannelData(channelId: channelId)
         .receive(on: DispatchQueue.main)
         .sink { _ in } receiveValue: { [weak self] chats in
            let sort = SortDescriptor(\Chat.createdAt, order: .forward)
            self?.chats = chats.sorted(using: sort)
         }
         .store(in: &store)
   }
}

// MARK: Chat Save
extension ChannelViewModel {
   private func sendChannelChat() async {
      let chatInput : CommonChatInput = .init(content: .init(content: chatText), files: [])
      let input : ChatInputType = .init(loungeId: loungeId, roomId: channelId, chatInput: chatInput)
      
      await diContainer.services.channelService.sendChannelChat(input: input)
         .receive(on: DispatchQueue.main)
         .sink { error in
            if case let .failure(errors) = error {
               print(errors.errorMessage)
            }
         } receiveValue: { chatOutput in
            Task { [weak self] in
               guard let self else { return }
               let saveRequest : ChatSaveRequestType = chatOutput.toSaveRequest
               await saveMyChat(for: saveRequest)
            }
         }
         .store(in: &store)
   }
   
   @MainActor
   private func saveMyChat(for chat: ChatSaveRequestType) async {
      if chats.filter({ $0.id == chat.chatId }).count == 0 {
         let savedChat = await diContainer.services.channelService.saveChannelChat(
            loungeId: loungeId,
            chatRequest: chat
         )
         chats.append(savedChat)
         chatText = ""
      }
   }
   
   @MainActor
   private func saveReceivedChat(for chat : ChatSaveRequestType) async {
      await diContainer.services.channelService.saveReceivedChat(
         loungeId: loungeId,
         chatRequest: chat
      )
      .receive(on: DispatchQueue.main)
      .sink { [weak self] chat in
         if let chat {
            self?.chats.append(chat)
            self?.chatText = ""
         }
      }
      .store(in: &store)
   }
}

// MARK: Socket
extension ChannelViewModel {
   private func connectSocket() async {
      await diContainer.services.channelService.connectSocket(channelId: channelId) { receivedChat in
         do {
            let chat = try JSONDecoder().decode(ChannelChatOutputType.self, from: receivedChat)
            Task { [weak self] in
               await self?.saveReceivedChat(for: chat.toSaveRequest)
            }
         } catch {
            print(error)
         }
      }
   }
   
   private func disconnectSocket() async {
      await diContainer.services.channelService.disconnectSocket()
   }
   
   private func pushToSettingView() {
      diContainer.navigator.push(to: .channelSetting(channelId: channelId, loungeId: loungeId))
   }
}
