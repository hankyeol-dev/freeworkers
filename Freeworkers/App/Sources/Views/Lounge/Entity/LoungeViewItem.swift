// hankyeol-dev.

import Foundation

struct LoungeListViewItem : Hashable {
   let loungeId : String
   let loungeName : String
   let description : String?
   let coverImage : String
}

struct LoungeViewItem : Hashable {
   let loungeId : String
   let name : String
   let description : String?
   let coverImage : String
   var channels : [ChannelCommonOutputType]
}

struct LougneChannelViewItem : Hashable {
   let channelId : String
   let channelName : String
}
