// hankyeol-dev.

import Foundation

struct ChatSaveRequestType {
   let roomId : String // MARK: channelId, dm roomId
   let chatId : String
   let content : String
   let files : [String]
   let created_at : String
   let user : UserCommonOutputType
}
