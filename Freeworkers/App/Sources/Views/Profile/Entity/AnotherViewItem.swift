// hankyeol-dev.

import Foundation

struct AnotherViewItem : Hashable {
   let userId : String
   let email : String
   let nickname : String
   let profileImage : String?
   
   var toDefaultImage : String {
      return "person.fill"
   }
}
