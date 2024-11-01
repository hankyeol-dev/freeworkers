// hankyeol-dev.

import Foundation

protocol ServiceType {
   var authService : AuthServiceType { get set }
   var validateService : ValidateServiceType { get set }
   var userService : UserServiceType { get set }
}

final class Services: ServiceType {
   var authService : AuthServiceType
   var validateService: ValidateServiceType
   var userService: UserServiceType
   
   init() {
      self.authService = AuthService(authRepository: AuthRepository())
      self.validateService = ValidateService()
      self.userService = UserService(userRepository: UserRepository())
   }
}
