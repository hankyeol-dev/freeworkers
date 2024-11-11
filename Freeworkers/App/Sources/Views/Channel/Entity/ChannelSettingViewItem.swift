// hankyeol-dev.

import Foundation

struct ChannelSettingViewItem : Hashable {
   let channelName : String
   let channelDescription : String?
   let isOwner : Bool
   let members : [UserCommonOutputType]
}
