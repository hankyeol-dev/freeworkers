// hankyeol-dev.

import Foundation
import Combine

protocol ValidateServiceType {
   func validateEmail(_ email: String) -> Bool
   func validatePassword(_ password: String) -> Bool
   func validateRoungeName(_ name: String) -> Bool
   func validateIsLoungeOwner(_ ownerId : String) async -> Bool
   func validateIsMe(_ userId : String) async -> AnyPublisher<Bool, Never>
}

struct ValidateService : ValidateServiceType {
   /// - 이메일 유효성 검사
   func validateEmail(_ email: String) -> Bool {
      let regex = "[A-Z0-9a-z._-]+@[A-Za-z0-9.-]+\\.[a-z]{2,64}"
      return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
   }
   
   /// - 비밀번호 유효성 검사
   func validatePassword(_ password: String) -> Bool {
      let regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
      return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
   }
   
   /// - Freeworkers Lounge Name 유효성 검사
   func validateRoungeName(_ name : String) -> Bool {
      return name.count >= 1 && name.count < 30
   }
   
   /// - Lounge Setting View에서 유저 라운지 소유 여부 검사
   func validateIsLoungeOwner(_ ownerId: String) async -> Bool {
      let userId = await UserDefaultsRepository.shared.getValue(.userId)
      return ownerId == userId
   }
   
   /// - Profile View에서 유저가 해당 유저인지 확인
   func validateIsMe(_ userId : String) async -> AnyPublisher<Bool, Never> {
      let appUserId = await UserDefaultsRepository.shared.getValue(.userId)
      return Just(userId == appUserId).eraseToAnyPublisher()
   }
}
