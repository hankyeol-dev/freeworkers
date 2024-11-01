// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

extension EndpointProtocol {
   var baseURL: String {
      AppEnvironment.baseURL
   }
   
   func setHeader(_ routerType: RouterType, needToken: Bool, boundary: String? = nil) async -> [String : String] {
      var header = [
         AppEnvironment.secretKey: AppEnvironment.secret,
         AppEnvironment.contentTypeKey 
         : routerType == .upload 
         ? AppEnvironment.contentMultipart + "; boundary=\(boundary ?? UUID().uuidString)"
         : AppEnvironment.contentDefault
      ]
      
      if needToken {
         header[AppEnvironment.authorizationKey] = await UserDefaultsRepository.shared.getValue(.accessToken)
      }

      if routerType == .refresh {
         header[AppEnvironment.refreshTokenKey] = await UserDefaultsRepository.shared.getValue(.refreshToken)
      }
       
      return header
   }
}
