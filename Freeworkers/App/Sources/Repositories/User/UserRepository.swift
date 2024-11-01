// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

protocol UserRepositoryType : CoreRepositoryType {
   func getMe() async -> Result<MeViewItem, RepositoryErrors>
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
            return .failure(.error(message: AppConstants.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: AppConstants.ERROR_UNKWON))
         }
      }
      
      return .failure(.error(message: AppConstants.ERROR_UNKWON))
   }
}
