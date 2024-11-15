// hankyeol-dev.

import Foundation

struct GetChatsInputType {
   let loungeId : String
   let roomId : String
   let createdAt : String? // MARK: DB에서 조회된 마지막 저장 시점
}

struct GetChatsUnreadsOutputType : Decodable {
   let count : Int
}

/**
 {
   "channel_id": "68265ef7-a91a-4522-a05b-5475088a61d6",
   "name": "새싹",
   "count": 100
 }
 */
