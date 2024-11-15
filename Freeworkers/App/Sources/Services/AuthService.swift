// hankyeol-dev.

import Foundation
import Combine
import AuthenticationServices

protocol AuthServiceType {
   func join(input : JoinInputType) async -> AnyPublisher<Bool, ServiceErrors>
   func login(input : LoginInputType) async -> AnyPublisher<Bool, ServiceErrors>
   func loginWithApple(authorization : ASAuthorization) async -> AnyPublisher<Bool, ServiceErrors>
   func logout() async
   func validIsLogined() async -> Just<Bool>
   func getLatestEnteredChannel() -> Just<String>
   func setLatestEnteredChannel(loungeId : String)
}

final class AuthService : AuthServiceType {
   private let authRepository : AuthRepositoryType
   
   init(authRepository: AuthRepositoryType) {
      self.authRepository = authRepository
   }
   
   func join(input: JoinInputType) async -> AnyPublisher<Bool, ServiceErrors>  {
      let joinState = await authRepository.join(input: input)
      
      return Future { promise in
         switch joinState {
         case let .success(success):
            promise(.success(success))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func login(input: LoginInputType) async -> AnyPublisher<Bool, ServiceErrors> {
      let loginState = await authRepository.login(input: input)
      
      return Future { promise in
         switch loginState {
         case let .success(success):
            promise(.success(success))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func loginWithApple(authorization: ASAuthorization) async -> AnyPublisher<Bool, ServiceErrors> {
      if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
         let appleIdToken = appleIdCredential.identityToken,
         let appleIdTokenString = String(data: appleIdToken, encoding: .utf8),
         let username = appleIdCredential.fullName {
         
         // 2. Credential을 통해서 IdToken을 가지고 왔다면 통신
         let givenName = username.givenName
         let familynName = username.familyName
         let nickname: String? = (givenName ?? "유저") + " " + (familynName ?? "애플 로그인")
         let input: LoginWithAppleInputType = .init(idToken: appleIdTokenString,
                                                    nickname: nickname,
                                                    deviceToken: nil)
         
         let loginState = await authRepository.loginWithApple(input: input)
         return Future { promise in
            if case .success = loginState {
               promise(.success(true))
            }
            
            if case .failure = loginState {
               promise(.failure(.error(message: errorText.ERROR_LOGIN_WITH_APPLE)))
            }
         }.eraseToAnyPublisher()
      } else {
         return Future { promise in
            promise(.failure(.error(message: errorText.ERROR_LOGIN_WITH_APPLE)))
         }.eraseToAnyPublisher()
      }
   }
   
   func logout() async { await authRepository.logout() }
   
   func validIsLogined() async -> Just<Bool> {
      let isLogined = await UserDefaultsRepository.shared.getLoginState()
      return Just(isLogined)
   }
   
   func getLatestEnteredChannel() -> Just<String> {
      guard let latestEnteredChannel = UserDefaults.standard.string(
         forKey: AppEnvironment.UserDefaultsKeys.latestEnteredChannelId.rawValue
      )
      else { return Just("") }
      return Just(latestEnteredChannel)
   }
   
   func setLatestEnteredChannel(loungeId : String) {
      UserDefaults.standard.setValue(
         loungeId,
         forKey: AppEnvironment.UserDefaultsKeys.latestEnteredChannelId.rawValue)
   }
}

