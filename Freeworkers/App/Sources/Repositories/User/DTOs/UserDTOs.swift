// hankyeol-dev.

import Foundation

struct UserCommonOutputType : Decodable, Hashable {
   let user_id : String
   let email : String
   let nickname : String
   let profileImage : String?
}
