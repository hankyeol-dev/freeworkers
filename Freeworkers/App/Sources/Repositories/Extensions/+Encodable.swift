// hankyeol-dev.

import Foundation

extension Encodable {
   var toJSON: Data? {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let json = try? encoder.encode(self)
      
      return json
   }
}
