// hankyeol-dev.

import Foundation

public enum SocketConnectionType : Hashable {
   case channel(channelId : String)
   case dm(roomId : String)
   
   var toNameSpace : String {
      switch self {
      case let .channel(channelId):
         return "/ws-channel-\(channelId)"
      case let .dm(roomId):
         return "/ws-dm-\(roomId)"
      }
   }
   
   var toEmitName : String {
      switch self {
      case .channel:
         return "channel"
      case .dm:
         return "dm"
      }
   }
}
