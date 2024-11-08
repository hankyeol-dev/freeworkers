// hankyeol-dev.

import SwiftUI

enum LoungeTabItem : Hashable, CaseIterable {
   case home
   case directMessage
   case search
   case setting
   
   var toActiveImage : Image {
      switch self {
      case .home:
         return .homeActiveIcon
      case .directMessage:
         return .directActiveIcon
      case .search:
         return .searchActiveIcon
      case .setting:
         return .settingActiveIcon
      }
   }
   
   var toInActiveImage : Image {
      switch self {
      case .home:
         return .homeIcon
      case .directMessage:
         return .directIcon
      case .search:
         return .searchIcon
      case .setting:
         return .settingIcon
      }
   }
}
