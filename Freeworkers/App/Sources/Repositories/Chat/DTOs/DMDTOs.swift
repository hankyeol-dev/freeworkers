// hankyeol-dev.

import Foundation

struct OpenDMInputType {
   let loungeId : String
   let input : input
   
   struct input : Encodable {
      let opponent_id : String
   }
}

struct CommonDMOutputType : Decodable {
   let room_id : String
   let createdAt : String
   let user : UserCommonOutputType
   
   var toLoungeDMViewItem : LoungeDMViewItem {
      return .init(roomId: room_id, opponent: user)
   }
   
   var toOpenDMItem : OpenDMItem {
      return .init(roomId: room_id)
   }
}

struct DMChatOutputType : Decodable {
   let dm_id : String
   let room_id : String
   let content : String?
   let createdAt : String
   let files : [String]
   let user : UserCommonOutputType
   
   var toSaveRequest : ChatSaveRequestType {
      return .init(roomId: room_id,
                   chatId: dm_id,
                   content: content ?? "",
                   files: files,
                   created_at: createdAt,
                   user: user)
   }
}
