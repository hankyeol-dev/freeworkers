// hankyeol-dev.

import Foundation

enum ImageExpireType {
   case sec(TimeInterval)
   case day(Int)
   
   func estimateExpire() -> Date {
      switch self {
      case let .sec(interval):
         return Date().addingTimeInterval(interval)
         
      case let .day(days):
         return Date().addingTimeInterval(TimeInterval(86400) * TimeInterval(days))
      }
   }
}
