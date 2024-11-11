// hankyeol-dev.

import Foundation

import FreeworkersNetworkKit
import FreeworkersDBKit

protocol ChannelRepositoryType : CoreRepositoryType {
   // GET
   func getChannelInfo(input : CommonChannelInputType) async -> Result<ChannelInfoOutputType, RepositoryErrors>
   func getChannelData(channelId : String) async -> Result<[Chat], RepositoryErrors>
   func getChannelChats(input : GetChatsInputType) async -> Result<[ChannelChatOutputType], RepositoryErrors>
   
   // POST
   func createChannel(input : CreateChannelInputType) async -> Result<ChannelCommonOutputType, RepositoryErrors>
   func sendChannelChat(input : ChatInputType) async -> Result<ChannelChatOutputType, RepositoryErrors>
   func saveChat(loungeId : String, chatRequest : ChatSaveRequestType) async -> Chat
   func saveReceivedChat(loungeId : String, chatRequest : ChatSaveRequestType) async -> Chat?
   
   // SOCKET
   func connectSocket(channelId : String, dataHanlder : @escaping (Data) -> Void) async
   func disconnectSocket() async
}

// MARK: - GET
struct ChannelRepository : ChannelRepositoryType {
   func getChannelInfo(input: CommonChannelInputType) async -> Result<ChannelInfoOutputType, RepositoryErrors> {
      let result = await request(router: ChannelRouter.getChannel(inputType: input),
                                 of: ChannelInfoOutputType.self)
      switch result {
      case let .success(output):
         return .success(output)
      case let .failure(errors):
         switch errors {
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
   
   func getChannelData(channelId: String) async -> Result<[Chat], RepositoryErrors> {
      let predicator: Predicate<Chat> = #Predicate<Chat> { chat in
         chat.roomId == channelId
      }
      let chats = await DatabaseService.shared.fetchRecords(predicator)
      if let chats {
         return .success(chats)
      } else {
         return .failure(.error(message: errorText.NO_CHANNEL_DATA))
      }
   }
   
   func getChannelChats(input: GetChatsInputType) async -> Result<[ChannelChatOutputType], RepositoryErrors> {
      let result = await request(router: ChannelRouter.getChannelChat(inputType: input),
                                 of: [ChannelChatOutputType].self)
      
      switch result {
      case let .success(output):
         return .success(output)
      case let .failure(errors):
         switch errors {
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
}

// MARK: - POST
extension ChannelRepository {
   func createChannel(input: CreateChannelInputType) async -> Result<ChannelCommonOutputType, RepositoryErrors> {
      let result = await request(router: ChannelRouter.createChannel(inputType: input),
                                 of: ChannelCommonOutputType.self)
      switch result {
      case let .success(output):
         return .success(output)
      case let .failure(error):
         switch error {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_BAD_REQUEST))
         case .error(.E12):
            return .failure(.error(message: errorText.ERROR_ROUNGENAME_OVERLAP))
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
   
   func sendChannelChat(input: ChatInputType) async -> Result<ChannelChatOutputType, RepositoryErrors> {
      let result = await request(router: ChannelRouter.sendChannelChat(inputType: input),
                                 of: ChannelChatOutputType.self)
      
      switch result {
      case let .success(chat):
         return .success(chat)
      case let .failure(error):
         switch error {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_BAD_REQUEST))
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
   
   func saveChat(loungeId : String, chatRequest: ChatSaveRequestType) async -> Chat {
      let me: Bool = (await UserDefaultsRepository.shared.getValue(.userId)) == chatRequest.user.user_id
      let chat: Chat = .init(id: chatRequest.chatId,
                             content: chatRequest.content,
                             files: chatRequest.files,
                             createdAt: chatRequest.created_at,
                             loungeId: loungeId,
                             roomId: chatRequest.roomId,
                             userId: chatRequest.user.user_id,
                             username: chatRequest.user.nickname,
                             userProfileImage: chatRequest.user.profileImage,
                             me: me)
      await DatabaseService.shared.addRecord(chat)
      return chat
   }
   
   func saveReceivedChat(loungeId: String, chatRequest: ChatSaveRequestType) async -> Chat? {
      let me: Bool = (await UserDefaultsRepository.shared.getValue(.userId)) == chatRequest.user.user_id
      
      if !me {
         return await saveChat(loungeId: loungeId, chatRequest: chatRequest)
      } else {
         return nil
      }
   }
}

// MARK: - SOCKET
extension ChannelRepository {
   func connectSocket(channelId : String, dataHanlder : @escaping (Data) -> Void) async {
      await SocketService.shared.connect(ChatRouter.enterChannel(channelId: channelId)) { message in
         dataHanlder(message)
      }
   }
   
   func disconnectSocket() async {
      await SocketService.shared.disconnect()
   }
}
