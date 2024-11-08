// hankyeol-dev.

import Foundation

struct ChannelCommonOutputType : Decodable, Hashable {
   let channel_id : String
   let name : String
   let description : String?
   let coverImage : String?
   let owner_id : String
   let createdAt : String
   
   var toLoungeChannelViewItem : LougneChannelViewItem {
      return .init(channelId: channel_id, channelName: name)
   }
}
