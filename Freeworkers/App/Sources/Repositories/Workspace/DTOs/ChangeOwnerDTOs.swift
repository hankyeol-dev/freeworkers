// hankyeol-dev.

import Foundation

struct ChangeOwnerInputType {
   let loungeId : String
   let input : ChangeOwnerIdInput
   
   struct ChangeOwnerIdInput : Encodable {
      let owner_id : String
   }
}

