// hankyeol-dev.

import Foundation

extension String {
   func toISO860() -> Date {
      let formatter = ISO8601DateFormatter()
      formatter.timeZone = .autoupdatingCurrent
      return formatter.date(from: self) ?? Date()
   }
}

extension Date {
   func toChatDate() -> String {
      let formatter = DateFormatter()
      formatter.locale = .autoupdatingCurrent
      formatter.dateFormat = "MM월 dd일"
      return formatter.string(from: self)
   }
}
