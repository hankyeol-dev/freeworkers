// hankyeol-dev.

import Foundation

struct GetLoungeInputType {
   let loungeId : String
}

struct GetLoungeOutputType : Decodable {
   let workspace_id : String
   let name : String
   let description : String?
   let coverImage : String
   let owner_id : String
   let createdAt : String
   
   let channels : [ChannelCommonOutputType]
   let workspaceMembers : [UserCommonOutputType]
   
   var toViewItem : LoungeViewItem {
      return .init(loungeId: workspace_id,
                   name: name,
                   description: description,
                   coverImage: coverImage,
                   channels: channels)
   }
}
