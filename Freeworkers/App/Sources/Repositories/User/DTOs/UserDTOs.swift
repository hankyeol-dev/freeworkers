// hankyeol-dev.

import Foundation

struct UserCommonOutputType : Decodable, Hashable {
   let user_id : String
   let email : String
   let nickname : String
   let profileImage : String?
   
   var toAnotherViewItem : AnotherViewItem {
      return .init(userId: user_id,
                   email: email,
                   nickname: nickname,
                   profileImage: profileImage)
   }
}
