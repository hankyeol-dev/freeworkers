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
      return .init(nickname: nickname, phone: phone, profileImage: profileImage, sesacCoin: sesacCoin)
   }
}

struct MeViewItem : Hashable {
   let nickname : String
   let phone : String?
   let profileImage : String?
   let sesacCoin : Int
}
