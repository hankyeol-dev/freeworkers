// hankyeol-dev.

import Foundation

struct OpenDMItem : Hashable {
   let roomId : String
}

struct DMListViewItemWithUnreads : Hashable {
   let dmViewItem : LoungeDMViewItem
   var lastDM : String
   var unreads : Int
}
