// hankyeol-dev.

import Foundation

protocol ServiceType {
   var authService : AuthServiceType { get set }
   var validateService : ValidateServiceType { get set }
   var userService : UserServiceType { get set }
   var workspaceService : WorkspaceServiceType { get set }
   var channelService : ChannelServiceType { get set }
}

final class Services: ServiceType {
   var authService : AuthServiceType
   var validateService: ValidateServiceType
   var userService: UserServiceType
   var workspaceService: WorkspaceServiceType
   var channelService: ChannelServiceType
   
   init() {
      self.authService = AuthService(authRepository: AuthRepository())
      self.validateService = ValidateService()
      self.userService = UserService(userRepository: UserRepository())
      self.workspaceService = WorkspaceService(workspaceRepository: WorkspaceRepository())
      self.channelService = ChannelService(channelRepository: ChannelRepository())
   }
}
