// hankyeol-dev.

import Foundation

protocol ValidateServiceType {
   func validateEmail(_ email: String) -> Bool
   func validatePassword(_ password: String) -> Bool
}

struct ValidateService : ValidateServiceType {
   /// - 이메일 유효성 검사
   func validateEmail(_ email: String) -> Bool {
      let regex = "[A-Z0-9a-z._-]+@[A-Za-z0-9.-]+\\.[a-z]{2,64}"
      return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
   }
   
   /// - 비밀번호 유효성 검사
   func validatePassword(_ password: String) -> Bool {
//      let regex = "[^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])]{8,20}"
      let regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
      return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
   }
}