// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum UserRouter : EndpointProtocol {
   case me
   
   var path: String {
      switch self {
      case .me:
         return "/users/me"
      }
   }
   
   var method: NetworkMethod {
      switch self {
      case .me:
         return .GET
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
