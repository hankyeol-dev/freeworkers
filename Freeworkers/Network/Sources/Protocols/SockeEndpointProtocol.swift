// hankyeol-dev.

import Foundation

public protocol SockeEndpointProtocol {
   var baseURL : String { get }
   var path : String { get }
   var pingInterval : TimeInterval { get }
}

extension SockeEndpointProtocol {
   func asSocketURL() throws -> URL {
      if let url = URL(string: baseURL + path) {
         return url
      } else {
         throw EndpointErrors.error(message: NetworkConstants.ERROR_INVALID_URL)
      }
   }
   
   func asSocketRequest() throws -> URLRequest {
      guard let url = try? asSocketURL() else {
         throw EndpointErrors.error(message: NetworkConstants.ERROR_INVALID_URL)
      }
      return URLRequest(url: url)
   }
}
