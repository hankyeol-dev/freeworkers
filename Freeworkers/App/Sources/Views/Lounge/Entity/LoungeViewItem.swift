// hankyeol-dev.

import Foundation

struct LoungeListViewItem : Hashable {
   let loungeId : String
   let loungeName : String
   let description : String?
   let coverImage : String
   let ownerId :  String
}

struct LoungeViewItem : Hashable {
   let loungeId : String
   let name : String
   let description : String?
   let coverImage : String
   let ownerId : String
}

struct LoungeChannelViewItem : Hashable {
   let channelId : String
   let channelName : String
}
