// hankyeol-dev.

import Foundation
import Combine
import FreeworkersDBKit

protocol ChannelServiceType {
   // GET
   func getChannelData(channelId : String) async -> AnyPublisher<[Chat], ServiceErrors>
   func getChannelChats(input : GetChatsInputType) async -> AnyPublisher<[ChannelChatOutputType], ServiceErrors>
   
   // POST
   func createChannel(input : CreateChannelInputType) async -> AnyPublisher<ChannelCommonOutputType, ServiceErrors>
   func sendChannelChat(input : ChatInputType) async -> AnyPublisher<ChannelChatOutputType, ServiceErrors>
   func saveChannelChat(loungeId: String, chat : ChatSaveRequestType) async -> Chat
}

final class ChannelService : ChannelServiceType {
   private let channelRepository : ChannelRepositoryType
   
   init(channelRepository: ChannelRepositoryType) {
      self.channelRepository = channelRepository
   }
}

// MARK: -GET
extension ChannelService {
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
   
   func saveChannelChat(loungeId: String, chat: ChatSaveRequestType) async -> Chat {
      return await channelRepository.saveChat(loungeId: loungeId, chat: chat)
   }
}
