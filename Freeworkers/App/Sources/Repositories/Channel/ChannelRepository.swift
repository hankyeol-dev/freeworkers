// hankyeol-dev.

import Foundation

import FreeworkersNetworkKit
import FreeworkersDBKit

protocol ChannelRepositoryType : CoreRepositoryType {
   // GET
   func getChannelData(channelId : String) async -> Result<[Chat], RepositoryErrors>
   func getChannelChats(input : GetChatsInputType) async -> Result<[ChannelChatOutputType], RepositoryErrors>
   
   // POST
   func createChannel(input : CreateChannelInputType) async -> Result<ChannelCommonOutputType, RepositoryErrors>
   func sendChannelChat(input : ChatInputType) async -> Result<ChannelChatOutputType, RepositoryErrors>
   func saveChat(loungeId : String, chat : ChatSaveRequestType) async -> Chat
   
   // SOCKET
}

// MARK: - GET
struct ChannelRepository : ChannelRepositoryType {
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
      let result = await request(router: ChannelRouter.getChannelChat(InputType: input),
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
      let result = await request(router: ChannelRouter.sendChannelChat(InputType: input),
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
   
   func saveChat(loungeId : String, chat: ChatSaveRequestType) async -> Chat {
      let me: Bool = (await UserDefaultsRepository.shared.getValue(.userId)) == chat.user.user_id
      let chat: Chat = .init(id: chat.chatId,
                             content: chat.content,
                             files: chat.files,
                             createdAt: chat.created_at,
                             loungeId: loungeId,
                             roomId: chat.roomId,
                             userId: chat.user.user_id,
                             username: chat.user.nickname,
                             userProfileImage: chat.user.profileImage,
                             me: me)
      await DatabaseService.shared.addRecord(chat)
      return chat
   }
}
