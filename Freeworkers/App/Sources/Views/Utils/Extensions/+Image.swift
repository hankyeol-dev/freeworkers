// hankyeol-dev.

import SwiftUI
import UIKit

extension Image {
   static let photoIcon: Image = .init("photoIcon")
   static let homeIcon: Image = .init("home")
   static let homeActiveIcon: Self = .init("home_active")
   static let directIcon: Self = .init("message")
   static let directActiveIcon : Self = .init("message_active")
   static let searchIcon: Self = .init("profile")
   static let searchActiveIcon : Self = .init("profile_active")
   static let settingIcon : Self = .init("setting")
   static let settingActiveIcon : Self = .init("setting_active")
}

extension UIImage {
   func downscaleTOjpegData(maxBytes: UInt) -> Data? {
      var quality = 1.0
      while quality > 0 {
         guard let jpeg = jpegData(compressionQuality: quality)
         else { return nil }
         if jpeg.count <= maxBytes {
            return jpeg
         }
         quality -= 0.1
      }
      return nil
   }
}
