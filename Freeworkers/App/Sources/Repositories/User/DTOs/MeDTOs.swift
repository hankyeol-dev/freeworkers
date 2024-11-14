// hankyeol-dev.

import Foundation

struct MeOutputType : Decodable {
   let user_id : String
   let email : String
   let nickname : String
   let profileImage : String?
   let phone : String?
   let provider : String?
   let sesacCoin : Int
   let createdAt : String
   
   func toMeViewItem() -> MeViewItem {
      return .init(userId : user_id,
                   email: email,
                   nickname: nickname,
                   phone: phone,
                   profileImage: profileImage,
                   provider: provider,
                   sesacCoin: sesacCoin)
   }
}
