// hankyeol-dev.

import Foundation

struct GetChatsInputType {
   let loungeId : String
   let roomId : String
   let createdAt : String? // MARK: DB에서 조회된 마지막 저장 시점
}
