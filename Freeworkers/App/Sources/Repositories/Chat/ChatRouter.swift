// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum ChatRouter : SocketEndpointProtocol {
   case enterChannel(channelId : String)
   case enterDM(roomId : String)
   
   var baseURL: String { return AppEnvironment.socketBaseURL }
   var connectionType: SocketConnectionType {
      switch self {
      case let .enterChannel(channelId):
            return .channel(channelId: channelId)
      case let .enterDM(roomId):
         return .dm(roomId: roomId)
      }
   }
}
