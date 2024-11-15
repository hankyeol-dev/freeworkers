// hankyeol-dev.

import Foundation
import Combine

import FreeworkersDBKit

protocol DMServiceType {
   // GET
   func getLoungeDms(loungeId : String) async -> AnyPublisher<[LoungeDMViewItem], ServiceErrors>
   func getDMDatas(loungeId: String, roomId: String) async -> AnyPublisher<[Chat], ServiceErrors>
   func getDms(input : GetChatsInputType) async -> AnyPublisher<[DMChatOutputType], ServiceErrors>
   
   // POST
   func openDms(input : OpenDMInputType) async -> AnyPublisher<OpenDMItem, ServiceErrors>
   func sendDM(input : ChatInputType) async -> AnyPublisher<DMChatOutputType, ServiceErrors>
   func saveDM(loungeId : String, chatRequest : ChatSaveRequestType) async -> Chat
   func saveReceivedDM(loungeId : String, chatRequest : ChatSaveRequestType) async -> Chat?
   
   // Socket
   func connect(roomId : String, dataHandler : @escaping (Data) -> Void) async
   func disconnect() async
}

final class DMService : DMServiceType {
   private let dmRepository : DMRepositoryType
   private let channelRepository : ChannelRepositoryType
   
   init(dmRepository: DMRepositoryType, channelRepository : ChannelRepositoryType) {
      self.dmRepository = dmRepository
      self.channelRepository = channelRepository
   }
}

// MARK: GET
extension DMService {
   func getLoungeDms(loungeId: String) async -> AnyPublisher<[LoungeDMViewItem], ServiceErrors> {
      let result = await dmRepository.getLoungeDms(loungeId: loungeId)
      return Future { promise in
         switch result {
         case let .success(output):
            promise(.success( output.map({ $0.toLoungeDMViewItem }) ))
         case let .failure(errors):
            promise(.failure(.error(message: errors.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func getDMDatas(loungeId: String, roomId: String) async -> AnyPublisher<[Chat], ServiceErrors> {
      let results = await dmRepository.getDMDatas(loungeId: loungeId, roomId: roomId)
      return Future { promise in
         switch results {
         case let .success(chats):
            promise(.success(chats))
         case let .failure(errors):
            promise(.failure(.error(message: errors.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func getDms(input: GetChatsInputType) async -> AnyPublisher<[DMChatOutputType], ServiceErrors> {
      let results = await dmRepository.getDms(input: input)
      return Future { promise in
         switch results {
         case let .success(output):
            promise(.success(output))
         case let .failure(errors):
            promise(.failure(.error(message: errors.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func getLastSavedDM(loungeId : String, roomId : String) async -> Chat? {
      let result = await dmRepository.getDMDatas(loungeId: loungeId, roomId: roomId)
      switch result {
      case let .success(chats):
         let sort = SortDescriptor(\Chat.createdAt, order: .forward)
         return chats.sorted(using: sort).last
      case .failure:
         return nil
      }
   }
}

// MARK: POST
extension DMService {
   func openDms(input: OpenDMInputType) async -> AnyPublisher<OpenDMItem, ServiceErrors> {
      let result = await dmRepository.openDms(input: input)
      return Future { promise in
         switch result {
         case let .success(output):
            promise(.success(output.toOpenDMItem))
         case let .failure(errors):
            promise(.failure(.error(message: errors.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func sendDM(input : ChatInputType) async -> AnyPublisher<DMChatOutputType, ServiceErrors> {
      let results = await dmRepository.sendDM(input: input)
      return Future { promise in
         switch results {
         case let .success(chats):
            promise(.success(chats))
         case let .failure(errors):
            promise(.failure(.error(message: errors.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func saveDM(loungeId : String, chatRequest : ChatSaveRequestType) async -> Chat {
      return await channelRepository.saveChat(loungeId: loungeId, chatRequest: chatRequest)
   }
   
   func saveReceivedDM(loungeId : String, chatRequest : ChatSaveRequestType) async -> Chat? {
      return await channelRepository.saveReceivedChat(loungeId: loungeId, chatRequest: chatRequest)
   }
}

// MARK: Socket
extension DMService {
   func connect(roomId : String, dataHandler : @escaping (Data) -> Void) async {
      await dmRepository.connectSocket(roomId: roomId, dataHanlder: dataHandler)
   }
   
   func disconnect() async {
      await dmRepository.disconnectSocket()
   }
}
