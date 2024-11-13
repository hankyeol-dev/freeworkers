// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum UserRouter : EndpointProtocol {
   case me
   case putNickname(inputType : PutNicknameDTO)
   case putPhone(inputType : PutPhoneDTO)
   
   var path: String {
      switch self {
      default:
         return "/users/me"
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .me:
         return .GET
      case .putNickname, .putPhone:
         return .PUT
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      default:
         return nil
      }
   }
   
   var body: Data? {
      switch self {
      case let .putNickname(inputType):
         return inputType.toJSON
      case let .putPhone(inputType):
         return inputType.toJSON
      default:
         return nil
      }
   }
   
   var headers: Task<[String : String], Never> {
      return Task {
         switch self {
         default:
            return await setHeader(.request, needToken: true)
         }
      }
   }
}
