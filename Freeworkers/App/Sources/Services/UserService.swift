// hankyeol-dev.

import Foundation
import Combine

protocol UserServiceType {
   func getMe() async -> AnyPublisher<MeViewItem, ServiceErrors>
   
   func putNickname(nickname : String) async -> Result<Bool, ServiceErrors>
   func putPhone(phone : String) async -> Result<Bool, ServiceErrors>
}

struct UserService : UserServiceType {
   private let userRepository : UserRepositoryType
   
   init(userRepository: UserRepositoryType) {
      self.userRepository = userRepository
   }
}

extension UserService { 
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

extension UserService {
   func putNickname(nickname: String) async -> Result<Bool, ServiceErrors> {
      let output = await userRepository.putNickname(nickname: nickname)
      switch output {
      case .success:
         return .success(true)
      case let .failure(errors):
         return .failure(.error(message: errors.errorMessage))
      }
   }
   
   func putPhone(phone: String) async -> Result<Bool, ServiceErrors> {
      let output = await userRepository.putPhone(phone: phone)
      switch output {
      case .success:
         return .success(true)
      case let .failure(errors):
         return .failure(.error(message: errors.errorMessage))
      }
   }
}
