// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum WorkspaceRouter : EndpointProtocol {
   case getLounges
   case getLounge(inputType : GetLoungeInputType)
   case getLoungeMembers(InputType : GetLoungeInputType)
   case inviteLounge(InputType : InviteLoungeInputType)
   case createLounge(inputType : CreateLoungeInputType)
   
   var path: String {
      switch self {
      case let .getLounge(input):
         return "/workspaces/\(input.loungeId)"
      case let .inviteLounge(InputType):
         return "/workspaces/\(InputType.loungeId)/members"
      case let .getLoungeMembers(InputType):
         return "/workspaces/\(InputType.loungeId)/members"
      default:
         return "/workspaces"
      }
   }
   
   var headers: Task<[String : String], Never> {
      switch self {
      case let .createLounge(inputType):
         return Task {
            return await setHeader(.upload, needToken: true, boundary: inputType.boundary)
         }
      default:
         return Task {
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
         
      case let .inviteLounge(inputType):
         return inputType.input.toJSON
      default:
         return nil
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .getLounges, .getLounge, .getLoungeMembers:
         return .GET
      case .createLounge, .inviteLounge:
         return .POST
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      default:
         return nil
      }
   }
}
