// hankyeol-dev.

import Foundation

struct ChatInputType {
   let boundary : String = UUID().uuidString
   let loungeId : String
   let roomId : String // MARK: channelId, directMessage roomId
   let chatInput : CommonChatInput
}

struct CommonChatInput {
   let content : ChatContent
   let files : [Data]
   
   struct ChatContent : Encodable {
      let content : String
   }
   var isFilesEmpty : Bool { files.isEmpty }
}

struct ChannelChatOutputType : Decodable {
   let channel_id : String
   let channelName : String
   let chat_id : String
   let content : String?
   let createdAt : String
   let files : [String]
   let user : UserCommonOutputType
   
   var toSaveRequest : ChatSaveRequestType {
      return .init(roomId: channel_id,
                   chatId: chat_id,
                   content: content ?? "",
                   files: files,
                   created_at: createdAt,
                   user: user)
   }
}
