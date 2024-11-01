// hankyeol-dev.

import Foundation

public enum NetworkErrors: Error {
   case error(message: NetworkErrorTypes)
}

public enum NetworkErrorTypes: String {
   case E00
   case E03
   case E05
   case E06
   case E11
   case E12
   case E99
}
