// hankyeol-dev.

import Foundation
import Combine
import FreeworkersDBKit
import FreeworkersNetworkKit

protocol ChannelServiceType {
   // GET
   func getChannelInfo(input : CommonChannelInputType) async -> AnyPublisher<ChannelSettingViewItem, ServiceErrors>
   func getChannelData(channelId : String) async -> AnyPublisher<[Chat], ServiceErrors>
   func getChannelChats(input : GetChatsInputType) async -> AnyPublisher<[ChannelChatOutputType], ServiceErrors>
   
   // POST
   func createChannel(input : CreateChannelInputType) async -> AnyPublisher<ChannelCommonOutputType, ServiceErrors>
   func sendChannelChat(input : ChatInputType) async -> AnyPublisher<ChannelChatOutputType, ServiceErrors>
   func saveChannelChat(loungeId: String, chatRequest : ChatSaveRequestType) async -> Chat
   func saveReceivedChat(loungeId : String, chatRequest : ChatSaveRequestType) async -> AnyPublisher<Chat?, Never>
   
   // SOCKET
   func connectSocket(channelId : String, dataHanlder : @escaping (Data) -> Void) async
   func disconnectSocket() async
}

final class ChannelService : ChannelServiceType {
   private let channelRepository : ChannelRepositoryType
   
   init(channelRepository: ChannelRepositoryType) {
      self.channelRepository = channelRepository
   }
}

// MARK: -GET
extension ChannelService {
   func getChannelInfo(input : CommonChannelInputType) async -> AnyPublisher<ChannelSettingViewItem, ServiceErrors> {
      let result = await channelRepository.getChannelInfo(input: input)
      let userId = await UserDefaultsRepository.shared.getValue(.userId)
      
      return Future { promise in
         switch result {
         case let .success(output):
            let viewItem: ChannelSettingViewItem = .init(
               channelName: output.name,
               channelDescription: output.description,
               isOwner: output.owner_id == userId,
               members: output.channelMembers)
            promise(.success(viewItem))
         case let .failure(errors):
            promise(.failure(.error(message: errors.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func getChannelData(channelId: String) async -> AnyPublisher<[Chat], ServiceErrors> {
      let result = await channelRepository.getChannelData(channelId: channelId)
      return Future { promise in
         switch result {
         case let .success(chats):
            promise(.success(chats))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func getChannelChats(input: GetChatsInputType) async -> AnyPublisher<[ChannelChatOutputType], ServiceErrors> {
      let result = await channelRepository.getChannelChats(input: input)
      return Future { promise in
         switch result {
         case let .success(output):
            promise(.success(output))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
}

// MARK: -Post
extension ChannelService {
   func createChannel(input: CreateChannelInputType) async -> AnyPublisher<ChannelCommonOutputType, ServiceErrors> {
      let createState = await channelRepository.createChannel(input: input)
      return Future { promise in
         switch createState {
         case let .success(output):
            promise(.success(output))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func sendChannelChat(input: ChatInputType) async -> AnyPublisher<ChannelChatOutputType, ServiceErrors> {
      let sendResult = await channelRepository.sendChannelChat(input: input)
      return Future { promise in
         switch sendResult {
         case let .success(chatOutput):
            promise(.success(chatOutput))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func saveChannelChat(loungeId: String, chatRequest: ChatSaveRequestType) async -> Chat {
      return await channelRepository.saveChat(loungeId: loungeId, chatRequest: chatRequest)
   }
   
   func saveReceivedChat(loungeId: String, chatRequest: ChatSaveRequestType) async -> AnyPublisher<Chat?, Never> {
      let chat = await channelRepository.saveReceivedChat(loungeId: loungeId, chatRequest: chatRequest)
      return Future { promise in
         if let chat {
            promise(.success(chat))
         } else {
            promise(.success(nil))
         }
      }.eraseToAnyPublisher()
   }
}

// MARK: -SOCKET
extension ChannelService {
   func connectSocket(channelId : String, dataHanlder : @escaping (Data) -> Void) async {
      await channelRepository.connectSocket(channelId: channelId, dataHanlder: dataHanlder)
   }
   
   func disconnectSocket() async {
      await channelRepository.disconnectSocket()
   }
}
