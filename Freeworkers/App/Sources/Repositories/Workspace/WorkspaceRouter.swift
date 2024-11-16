// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum WorkspaceRouter : EndpointProtocol {
   case getLounges
   case getLounge(inputType : GetLoungeInputType)
   case getLoungeMyChannel(loungeId : String)
   case getLoungeMembers(InputType : GetLoungeInputType)
   case inviteLounge(inputType : InviteLoungeInputType)
   case createLounge(inputType : CreateLoungeInputType)
   case editLounge(inputType : EditLoungeInputType)
   case changeLoungeOwner(inputType : ChangeOwnerInputType)
   case exitLounge(loungeId : String)
   
   var path: String {
      switch self {
      case let .getLounge(input):
         return "/workspaces/\(input.loungeId)"
      case let .editLounge(inputType):
         return "/workspaces/\(inputType.loungeId)"
      case let .getLoungeMyChannel(loungeId):
         return "/workspaces/\(loungeId)/my-channels"
      case let .inviteLounge(InputType):
         return "/workspaces/\(InputType.loungeId)/members"
      case let .getLoungeMembers(InputType):
         return "/workspaces/\(InputType.loungeId)/members"
      case let .changeLoungeOwner(inputType):
         return "/workspaces/\(inputType.loungeId)/transfer/ownership"
      case let .exitLounge(loungeId):
         return "/workspaces/\(loungeId)/exit"
      default:
         return "/workspaces"
      }
   }
   
   var headers: Task<[String : String], Never> {
      return Task {
         switch self {
         case let .createLounge(inputType):
            return await setHeader(.upload, needToken: true, boundary: inputType.boundary)
         case let .editLounge(inputType):
            if inputType.isImageEmpty {
               return await setHeader(.request, needToken: true)
            } else {
               return await setHeader(.upload, needToken: true, boundary: inputType.file.boundary)
            }
         default:
            return await setHeader(.request, needToken: true)
         }
      }
   }
   
   var body: Data? {
      switch self {
      case let .createLounge(inputType):
         return asMultipartFormDatas(boundary: inputType.boundary,
                                     files: inputType.input.image,
                                     content: inputType.input.toDict)
      case let .editLounge(inputType):
         if inputType.isImageEmpty {
            return inputType.content.toJSON
         } else {
            if let image = inputType.file.image {
               return asMultipartFormDatas(boundary: inputType.file.boundary,
                                           files: [image],
                                           content: asMultipartContentDatas(input: inputType.content))
            } else {
               return nil
            }
         }
      case let .inviteLounge(inputType):
         return inputType.input.toJSON
      case let .changeLoungeOwner(inputType):
         return inputType.input.toJSON
      default:
         return nil
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .getLounges, .getLounge, .getLoungeMembers, .getLoungeMyChannel, .exitLounge:
         return .GET
      case .createLounge, .inviteLounge:
         return .POST
      case .editLounge, .changeLoungeOwner:
         return .PUT
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      default:
         return nil
      }
   }
}
