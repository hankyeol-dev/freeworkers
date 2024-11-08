// hankyeol-dev.

import Foundation

struct CreateChannelInputType {
   let boundary : String = UUID().uuidString
   let loungeId : String
   let content : CreateChannelContentInput
   let image : [Data]?
   
   struct CreateChannelContentInput : Encodable {
      let name : String
      let description : String?
   }
}

struct CreateChannelRecordInputType {
   let channelId : String
   let loungeId : String
}
