// hankyeol-dev.

import Foundation
import Combine

protocol UserServiceType {
   func getMe() async -> AnyPublisher<MeViewItem, ServiceErrors>
}

struct UserService : UserServiceType {
   private let userRepository : UserRepositoryType
   
   init(userRepository: UserRepositoryType) {
      self.userRepository = userRepository
   }
   
   func getMe() async -> AnyPublisher<MeViewItem, ServiceErrors> {
      let output = await userRepository.getMe()
      
      return Future { promise in
         if case let .success(viewItem) = output {
            promise(.success(viewItem))
         }
         if case let .failure(errors) = output {
            promise(.failure(.error(message: errors.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
}
