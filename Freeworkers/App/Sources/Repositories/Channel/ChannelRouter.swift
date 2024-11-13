// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum ChannelRouter : EndpointProtocol {
   case getChannel(inputType : CommonChannelInputType)
   case createChannel(inputType : CreateChannelInputType)
   case sendChannelChat(inputType : ChatInputType)
   case getChannelChat(inputType : GetChatsInputType)
   
   var path: String {
      switch self {
      case let .getChannel(inputType):
         return "/workspaces/\(inputType.loungeId)/channels/\(inputType.channelId)"
      case let .createChannel(inputType):
         return "/workspaces/\(inputType.loungeId)/channels"
      case let .sendChannelChat(inputType):
         return "/workspaces/\(inputType.loungeId)/channels/\(inputType.roomId)/chats"
      case let .getChannelChat(inputType):
         return "/workspaces/\(inputType.loungeId)/channels/\(inputType.roomId)/chats"
      }
   }
   
   var method: FreeworkersNetworkKit.NetworkMethod {
      switch self {
      case .getChannelChat, .getChannel:
         return .GET
      default:
         return .POST
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      case let .getChannelChat(inputType):
         return [.init(name: "cursor_date", value: inputType.createdAt)]
      default:
         return nil
      }
   }
   
   var headers: Task<[String : String], Never> {
      return Task {
         switch self {
         case let .sendChannelChat(inputType):
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
   
   var body: Data? {
      switch self {
      case let .createChannel(inputType):
         return inputType.content.toJSON
      case let .sendChannelChat(inputType):
         if inputType.chatInput.isFilesEmpty {
            return inputType.chatInput.content.toJSON
         } else {
            return asMultipartFormDatas(boundary: inputType.boundary,
                                        fileKey: "files",
                                        files: inputType.chatInput.files,
                                        content: inputType.chatInput.content.content.isEmpty
                                        ? nil 
                                        : ["content" : inputType.chatInput.content.content])
         }
      default:
         return nil
      }
   }
}
