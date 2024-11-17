// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum UserRouter : EndpointProtocol {
   case me
   case another(userId : String)
   case putNickname(inputType : PutNicknameDTO)
   case putPhone(inputType : PutPhoneDTO)
   case paymentValidation(inputType : PaymentInputType)
   
   var path: String {
      switch self {
      case let .another(userId):
         return "/users/\(userId)"
      case .paymentValidation:
         return "/store/pay/validation"
      default:
         return "/users/me"
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .me, .another:
         return .GET
      case .paymentValidation:
         return .POST
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
      case let .paymentValidation(inputType):
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
