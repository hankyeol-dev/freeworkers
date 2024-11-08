// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

@propertyWrapper
fileprivate struct UserDefaultsWrapper<T> {
   private let standard = UserDefaults.standard
   private let key: AppEnvironment.UserDefaultsKeys
   let defaultValue: T
   
   init(key: AppEnvironment.UserDefaultsKeys, defaultValue: T) {
      self.key = key
      self.defaultValue = defaultValue
   }
   
   var wrappedValue: T {
      get {
         standard.value(forKey: key.rawValue) as? T ?? defaultValue
      }
      
      set {
         standard.setValue(newValue, forKey: key.rawValue)
      }
   }
}

fileprivate struct UserDefaultSetting {
   @UserDefaultsWrapper(key: .userId, defaultValue: "")
   var userId: String
   
   @UserDefaultsWrapper(key: .accessToken, defaultValue: "")
   var accessToken: String
   
   @UserDefaultsWrapper(key: .refreshToken, defaultValue: "")
   var refreshToken: String
   
   @UserDefaultsWrapper(key: .isLogined, defaultValue: false)
   var isLogined: Bool
   
   @UserDefaultsWrapper(key: .isLogined, defaultValue: "")
   var latestEnteredChannelId: String
}

protocol UserDefaultsRepositoryType : Actor {
   func setValue(_ key: AppEnvironment.UserDefaultsKeys, value: String)
   func getValue(_ key: AppEnvironment.UserDefaultsKeys) -> String
   func refreshToken() async -> Bool
}

final actor UserDefaultsRepository : UserDefaultsRepositoryType {
   static let shared : UserDefaultsRepository = .init()
   
   private var userSetting = UserDefaultSetting()
   
   private init() {}
   
   func setValue(_ key: AppEnvironment.UserDefaultsKeys, value: String) {
      switch key {
      case .userId:
         userSetting.userId = value
      case .accessToken:
         userSetting.accessToken = value
      case .refreshToken:
         userSetting.refreshToken = value
      case .latestEnteredChannelId:
         userSetting.latestEnteredChannelId = value
      default:
         break;
      }
   }
   
   func getValue(_ key: AppEnvironment.UserDefaultsKeys) -> String {
      switch key {
      case .userId:
         return userSetting.userId
      case .accessToken:
         return userSetting.accessToken
      case .refreshToken:
         return userSetting.refreshToken
      case .latestEnteredChannelId:
         return userSetting.latestEnteredChannelId
      default:
         return ""
      }
   }
   
   func refreshToken() async -> Bool {
      do {
         let accessToken = try await NetworkService.request(
            endpoint: AuthRouter.refresh,
            of: TokenRefreshOutputType.self
         ).accessToken
         
         setValue(.accessToken, value: accessToken)
         return true
      } catch {
         return false
      }
   }
   
   func setLoginState(_ isLogin : Bool) { userSetting.isLogined = isLogin }
   func getLoginState() -> Bool { return userSetting.isLogined }
}
