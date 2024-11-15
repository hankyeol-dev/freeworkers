// hankyeol-dev.

import Foundation

extension String {
   func toISO860() -> Date {
      let target : Self = String(self.split(separator: ".")[0]) + "Z"
      let formatter = ISO8601DateFormatter()
      formatter.timeZone = TimeZone(abbreviation: "KST")
      formatter.formatOptions = [.withInternetDateTime]
      return formatter.date(from: target) ?? Date()
   }
}

extension Date {
   func toChatDate() -> String {
      let formatter = DateFormatter()
      let calendar = Calendar.current
      formatter.locale = Locale(identifier: "ko_KR")
      formatter.timeZone = TimeZone(abbreviation: "KST")
     
      if calendar.isDateInToday(self) {
         let component = calendar.dateComponents([.hour, .minute], from: self, to: .now)
         if let hour = component.hour, let minute = component.minute {
            if hour == 0 && minute == 0 { return "지금" }
            if hour == 0 && minute != 0 {
               return "\(minute)분 전"
            }
            if hour != 0 && minute == 0 {
               formatter.dateFormat = "hh시간"
               return "\(hour)시간 전"
            }
            if hour != 0 && minute != 0 {
               formatter.dateFormat = "hh시간 mm분"
               return formatter.string(from: self) + " 전"
            }
         }
      } else {
         formatter.dateFormat = "MM월 dd일"
      }
            
      return formatter.string(from: self)
   }
}
