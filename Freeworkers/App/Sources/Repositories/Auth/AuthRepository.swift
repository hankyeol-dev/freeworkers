// hankyeol-dev.

import Foundation
import Combine
import FreeworkersNetworkKit

protocol AuthRepositoryType : CoreRepositoryType {
   func join(input: JoinInputType) async -> Result<Bool, RepositoryErrors>
   func login(input: LoginInputType) async -> Result<Bool, RepositoryErrors>
   func loginWithApple(input: LoginWithAppleInputType) async -> Result<Bool, RepositoryErrors>
   func logout() async
   func checkIsOverlapEmail(input: EmailValidInputType) async -> Result<Bool, RepositoryErrors>
}

struct AuthRepository : AuthRepositoryType {
   func join(input: JoinInputType) async -> Result<Bool, RepositoryErrors> {
      do {
         let data = try await NetworkService.request(endpoint: AuthRouter.join(inputType: input),
                                                     of: CommonAuthOutputType.self)
         await saveUserInformation(data)
         return .success(true)
      } catch NetworkErrors.error(message: .E11) {
         return .failure(.error(message: errorText.ERROR_JOIN_WRONGINPUT))
      } catch NetworkErrors.error(message: .E12) {
         return .failure(.error(message: errorText.ERROR_JOIN_OVERLAP))
      } catch {
         return .failure(.error(message: errorText.ERROR_UNKWON))
      }
   }
   
   func login(input: LoginInputType) async -> Result<Bool, RepositoryErrors> {
      do {
         let data = try await NetworkService.request(endpoint: AuthRouter.login(inputType: input),
                                                     of: CommonAuthOutputType.self)
         await saveUserInformation(data)
         await UserDefaultsRepository.shared.setLoginState(true)
         return .success(true)
      } catch NetworkErrors.error(message: .E03) {
         return .failure(.error(message: errorText.ERROR_LOGIN))
      } catch {
         return .failure(.error(message: errorText.ERROR_UNKWON))
      }
   }
   
   func loginWithApple(input: LoginWithAppleInputType) async -> Result<Bool, RepositoryErrors> {
      do {
         let data = try await NetworkService.request(
            endpoint: AuthRouter.loginWithApple(inputType: input),
            of: CommonAuthOutputType.self)
         await saveUserInformation(data)
         await UserDefaultsRepository.shared.setLoginState(true)
         return .success(true)
      } catch NetworkErrors.error(message: .E03) {
         return .failure(.error(message: errorText.ERROR_LOGIN_WITH_APPLE))
      } catch NetworkErrors.error(message: .E12) {
         return .failure(.error(message: errorText.ERROR_JOIN_OVERLAP))
      } catch {
         return .failure(.error(message: errorText.ERROR_UNKWON))
      }
   }
   
   func logout() async {
      await UserDefaultsRepository.shared.setValue(.accessToken, value: "")
      await UserDefaultsRepository.shared.setValue(.refreshToken, value: "")
      await UserDefaultsRepository.shared.setLoginState(false)
   }
   
   func checkIsOverlapEmail(input: EmailValidInputType) async -> Result<Bool, RepositoryErrors> {
      do {
         let data = try await NetworkService.request(endpoint: AuthRouter.emailValid(inputType: input),
                                                     of: EmailValidOutputType.self)
         print(data)
         return .success(true)
      } catch NetworkErrors.error(message: .E11) {
         return .failure(.error(message: errorText.ERROR_JOIN_WRONGINPUT))
      } catch NetworkErrors.error(message: .E12) {
         return .failure(.error(message: errorText.ERROR_JOIN_OVERLAP))
      } catch {
         return .failure(.error(message: errorText.ERROR_UNKWON))
      }
   }
}

extension AuthRepository {
   private func saveUserInformation(_ data: CommonAuthOutputType) async {
      await UserDefaultsRepository.shared.setValue(.accessToken, value: data.token.accessToken)
      await UserDefaultsRepository.shared.setValue(.refreshToken, value: data.token.refreshToken)
      await UserDefaultsRepository.shared.setValue(.userId, value: data.user_id)
   }
}
