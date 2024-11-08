// hankyeol-dev.

import Foundation

struct InviteLoungeInputType {
   let loungeId : String
   let input : InviteMemeberInput
   
   struct InviteMemeberInput : Encodable {
      let email : String
   }
}

