// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

protocol UserRepositoryType : CoreRepositoryType {
   func getMe() async -> Result<MeViewItem, RepositoryErrors>
   func getAnother(_ userId : String) async -> Result<UserCommonOutputType, RepositoryErrors>
   
   func putNickname(nickname : String) async -> Result<Bool, RepositoryErrors>
   func putPhone(phone : String) async -> Result<Bool, RepositoryErrors>
}

struct UserRepository : UserRepositoryType {
   func getMe() async -> Result<MeViewItem, RepositoryErrors> {
      let results = await request(router: UserRouter.me, of: MeOutputType.self)
      if case let .success(output) = results {
         return .success(output.toMeViewItem())
      }
      
      if case let .failure(errors) = results {
         switch errors {
         case .error(.E03):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
      
      return .failure(.error(message: errorText.ERROR_UNKWON))
   }
   
   func getAnother(_ userId : String) async -> Result<UserCommonOutputType, RepositoryErrors> {
      let result = await request(router: UserRouter.another(userId: userId),
                                 of: UserCommonOutputType.self)
      
      if case let .success(user) = result {
         return .success(user)
      }
      
      if case let .failure(errors) = result {
         switch errors {
         case .error(.E03):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
      
      return .failure(.error(message: errorText.ERROR_UNKWON))
   }
}

extension UserRepository {
   func putNickname(nickname: String) async -> Result<Bool, RepositoryErrors> {
      let result = await request(router: UserRouter.putNickname(inputType: .init(nickname: nickname)),
                                 of: PutNicknameDTO.self)
      print(result)
      if case .success = result {
         return .success(true)
      }
      
      if case let .failure(errors) = result {
         switch errors {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
      
      return .failure(.error(message: errorText.ERROR_UNKWON))
   }
   
   func putPhone(phone: String) async -> Result<Bool, RepositoryErrors> {
      let result = await request(router: UserRouter.putPhone(inputType: .init(phone: phone)),
                                 of: PutPhoneDTO.self)
      if case .success = result {
         return .success(true)
      }
      
      if case let .failure(errors) = result {
         switch errors {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
      
      return .failure(.error(message: errorText.ERROR_UNKWON))
   }
}
