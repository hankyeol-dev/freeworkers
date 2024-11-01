// hankyeol-dev.

import Foundation

extension Data {
   mutating func appendString(_ content: String) {
      if let data = content.data(using: .utf8) {
         self.append(data)
      }
   }
}
