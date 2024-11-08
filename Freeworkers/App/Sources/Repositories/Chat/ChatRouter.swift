// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

enum ChatRouter : SockeEndpointProtocol {
   case enterChannel(channelId : String)
   case enterDM(roomId : String)
   
   var path: String {
      switch self {
      case let .enterChannel(channelId):
         return "/ws-channel-\(channelId)"
      case let .enterDM(roomId):
         return "/ws-dm-\(roomId)"
      }
   }
   
   var pingInterval: TimeInterval {
      return TimeInterval(5)
   }
}
