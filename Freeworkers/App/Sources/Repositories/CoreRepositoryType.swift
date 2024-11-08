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
            await logout()
            return .failure(.error(message: .E00))
         }
      } catch {
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
}
