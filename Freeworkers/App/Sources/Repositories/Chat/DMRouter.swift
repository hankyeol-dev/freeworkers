// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum DMRouter : EndpointProtocol {
   case getDMLists(loungeId : String)
   case getDms(inputType : GetChatsInputType)
   case getDmUnreads(inputType : GetChatsInputType)
   
   case openDms(inputType : OpenDMInputType)
   case sendDm(inputType : ChatInputType)
   
   var path: String {
      switch self {
      case let .getDMLists(loungeId):
         return "/workspaces/\(loungeId)/dms"
      case let .getDms(inputType):
         return "/workspaces/\(inputType.loungeId)/dms/\(inputType.roomId)/chats"
      case let .getDmUnreads(inputType):
         return "/workspaces/\(inputType.loungeId)/dms/\(inputType.roomId)/unreads"
         
      case let .openDms(inputType):
         return "/workspaces/\(inputType.loungeId)/dms"
      case let .sendDm(inputType):
         return "/workspaces/\(inputType.loungeId)/dms/\(inputType.roomId)/chats"
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .getDMLists, .getDms, .getDmUnreads:
         return .GET
      case .openDms, .sendDm:
         return .POST
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      case let .getDms(inputType):
         return [.init(name: "cursor_date", value: inputType.createdAt)]
      case let .getDmUnreads(inputType):
         return [.init(name: "after", value: inputType.createdAt)]
      default:
         return nil
      }
   }
   
   var body: Data? {
      switch self {
      case let .openDms(inputType):
         return inputType.input.toJSON
      case let .sendDm(inputType):
         if inputType.chatInput.isFilesEmpty {
            return inputType.chatInput.content.toJSON
         } else {
            return asMultipartFormDatas(boundary: inputType.boundary,
                                        fileKey: "files",
                                        files: inputType.chatInput.files,
                                        content: inputType.chatInput.content.content.isEmpty
                                        ? nil
                                        : asMultipartContentDatas(input: inputType.chatInput.content)
            )
         }
      default:
         return nil
      }
   }
   
   var headers: Task<[String : String], Never> {
      return Task {
         switch self {
         case let .sendDm(inputType):
            if inputType.chatInput.isFilesEmpty {
               return await setHeader(.request, needToken: true)
            } else {
               return await setHeader(.upload, needToken: true, boundary: inputType.boundary)
            }
         default:
            return await setHeader(.request, needToken: true)
         }
      }
   }
}
