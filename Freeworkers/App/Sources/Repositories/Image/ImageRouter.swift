// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum ImageRouter : EndpointProtocol {
   case path(input : String)
   
   var path: String {
      switch self {
      case let .path(input):
         return input
      }
   }
   var method: NetworkMethod { .GET }
   var parameters: [URLQueryItem]? { nil }
   var headers: Task<[String : String], Never> {
      return Task {
         switch self {
         case .path:
            return await setHeader(.image, needToken: true)
         }
      }
   }
   var body: Data? { nil }
}
