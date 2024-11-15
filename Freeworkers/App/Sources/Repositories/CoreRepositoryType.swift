// hankyeol-dev.

import Foundation
import Combine

import FreeworkersNetworkKit

protocol CoreRepositoryType {
   func request<OutputType : Decodable>(router : EndpointProtocol, of : OutputType.Type) async -> Result<OutputType, NetworkErrors>
   func refreshToken() async -> Bool
}

extension CoreRepositoryType {
   func request<OutputType : Decodable>(
      router : EndpointProtocol,
      of : OutputType.Type
   ) async -> Result<OutputType, NetworkErrors> {
      do {
         let output = try await NetworkService.request(endpoint: router, of: of.self)
         return .success(output)
      } catch NetworkErrors.error(message: .E05) {
         // MARK: accessToken 만료
         let isRefresh = await refreshToken()
         if isRefresh {
            return await request(router: router, of: of)
         } else {
            await dummyLogin()
            return await request(router: router, of: of)
//            await logout()
//            return .failure(.error(message: .E00))
         }
      } 
//      catch NetworkErrors.error(message: .E06) {
//         await dummyLogin()
//         return await request(router: router, of: of)
//      } 
      catch {
         return .failure(error as? NetworkErrors ?? NetworkErrors.error(message: .E00))
      }
   }
   
   func refreshToken() async -> Bool {
      return await UserDefaultsRepository.shared.refreshToken()
   }
   
   @MainActor
   fileprivate func logout() async {
      await UserDefaultsRepository.shared.setValue(.accessToken, value: "")
      await UserDefaultsRepository.shared.setValue(.refreshToken, value: "")
      await UserDefaultsRepository.shared.setLoginState(false)
   }
   
   fileprivate func dummyLogin() async {
      let loginInput = AppEnvironment.dummyLoginInput
      let result = await request(router: AuthRouter.login(inputType: loginInput),
                                 of: CommonAuthOutputType.self)
      switch result {
      case let .success(output):
         await UserDefaultsRepository.shared.setValue(.accessToken, value: output.token.accessToken)
         await UserDefaultsRepository.shared.setValue(.refreshToken, value: output.token.refreshToken)
         await UserDefaultsRepository.shared.setValue(.userId, value: output.user_id)
         await UserDefaultsRepository.shared.setLoginState(true)
      default:
         break
      }
   }
}
