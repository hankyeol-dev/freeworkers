// hankyeol-dev.

import Foundation

struct LoungeListViewItem : Hashable {
   let loungeId : String
   let loungeName : String
   let description : String?
   let coverImage : String
   let ownerId :  String
   let createdAt : String
}

struct LoungeViewItem : Hashable {
   let loungeId : String
   let name : String
   let description : String?
   let coverImage : String
   let ownerId : String
   let createdAt : String
   let channels : [LoungeChannelViewItem]
}

struct LoungeChannelViewItem : Hashable {
   let channelId : String
   let channelName : String
}
