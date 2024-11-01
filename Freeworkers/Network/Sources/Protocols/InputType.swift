// hankyeol-dev.

import Foundation

public protocol InputType {
   var input: Encodable? { get }
}

public extension InputType {
   func asJSON() -> Data? {
      if let input {
         return try? JSONEncoder().encode(input)
      } else {
         return nil
      }
   }
}

public protocol MultipartInputType: InputType {
   var boundary: String { get }
   var data: [Data]? { get }
}
