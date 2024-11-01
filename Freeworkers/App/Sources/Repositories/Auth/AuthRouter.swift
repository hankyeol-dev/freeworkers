// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum AuthRouter: EndpointProtocol {
   case join(inputType: JoinInputType)
   case emailValid(inputType: EmailValidInputType)
   case login(inputType: LoginInputType)
   case loginWithApple(inputType: LoginWithAppleInputType)
   case refresh
   
   var path: String {
      switch self {
      case .join:
         return "/users/join"
      case .emailValid:
         return "/users/validation/email"
      case .login:
         return "/users/login"
      case .loginWithApple:
         return "/users/login/apple"
      case .refresh:
         return "/auth/refresh"
      }
   }
   
   var parameters: [URLQueryItem]? {
      switch self {
      default:
         nil
      }
   }
   
   var headers: Task<[String : String], Never> {
      return Task {
         switch self {
         case .refresh:
            return await setHeader(.refresh, needToken: true)
         default:
            return await setHeader(.request, needToken: false)
         }
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .refresh:
            .GET
      default:
            .POST
      }
   }
   
   var body: Data? {
      switch self {
      case let .join(inputType):
         return inputType.toJSON
      case let .emailValid(inputType):
         return inputType.toJSON
      case let .login(inputType):
         return inputType.toJSON
      case let .loginWithApple(inputType):
         return inputType.toJSON
      default:
         return nil
      }
   }
}
