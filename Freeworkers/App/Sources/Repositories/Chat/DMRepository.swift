// hankyeol-dev.

import Foundation

import FreeworkersNetworkKit
import FreeworkersDBKit

protocol DMRepositoryType : CoreRepositoryType {
   // GET
   func getLoungeDms(loungeId : String) async -> Result<[CommonDMOutputType], RepositoryErrors>
   func getDMDatas(loungeId : String, roomId : String) async -> Result<[Chat], RepositoryErrors>
   func getDms(input : GetChatsInputType) async -> Result<[DMChatOutputType], RepositoryErrors>
   func getDmUnreads(input : GetChatsInputType) async -> GetChatsUnreadsOutputType? 
   
   // POST
   func openDms(input : OpenDMInputType) async -> Result<CommonDMOutputType, RepositoryErrors>
   func sendDM(input : ChatInputType) async -> Result<DMChatOutputType, RepositoryErrors>
   
   // SOCKET
   func connectSocket(roomId : String, dataHanlder : @escaping (Data) -> Void) async
   func disconnectSocket() async
}

struct DMRepository : DMRepositoryType {}

// MARK: GET
extension DMRepository {
   func getLoungeDms(loungeId: String) async -> Result<[CommonDMOutputType], RepositoryErrors> {
      let result = await request(router: DMRouter.getDMLists(loungeId: loungeId),
                                 of: [CommonDMOutputType].self)
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
   
   func getDMDatas(loungeId: String, roomId: String) async -> Result<[Chat], RepositoryErrors> {
      let predicator: Predicate<Chat> = #Predicate<Chat> { chat in
         (chat.loungeId == loungeId) && (chat.roomId == roomId)
      }
      let chats = await DatabaseService.shared.fetchRecords(predicator)
      
      if let chats {
         return .success(chats)
      } else {
         return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
      }
   }
   
   func getDms(input : GetChatsInputType) async -> Result<[DMChatOutputType], RepositoryErrors> {
      let result = await request(router: DMRouter.getDms(inputType: input),
                                 of: [DMChatOutputType].self)
      
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
   
   func getDmUnreads(input : GetChatsInputType) async -> GetChatsUnreadsOutputType? {
      let result = await request(router: DMRouter.getDmUnreads(inputType: input),
                                 of: GetChatsUnreadsOutputType.self)
      
      if case let .success(unreads) = result {
         return unreads
      }
      
      if case .failure = result {
         return nil
      }
      
      return nil
   }
}

// MARK: POST
extension DMRepository {
   func openDms(input: OpenDMInputType) async -> Result<CommonDMOutputType, RepositoryErrors> {
      let output = await request(router: DMRouter.openDms(inputType: input),
                                 of: CommonDMOutputType.self)
      switch output {
      case let .success(result):
         return .success(result)
      case let .failure(errors):
         switch errors {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_BAD_REQUEST))
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
   
   func sendDM(input: ChatInputType) async -> Result<DMChatOutputType, RepositoryErrors> {
      let output = await request(router: DMRouter.sendDm(inputType: input),
                                 of: DMChatOutputType.self)
      
      switch output {
      case let .success(result):
         return .success(result)
      case let .failure(errors):
         switch errors {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_BAD_REQUEST))
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
}

// MARK: SOCKET
extension DMRepository {
   func connectSocket(roomId : String, dataHanlder : @escaping (Data) -> Void) async {
      await SocketService.shared.connect(ChatRouter.enterDM(roomId: roomId)) { message in
         dataHanlder(message)
      }
   }
   
   func disconnectSocket() async {
      await SocketService.shared.disconnect()
   }
}
