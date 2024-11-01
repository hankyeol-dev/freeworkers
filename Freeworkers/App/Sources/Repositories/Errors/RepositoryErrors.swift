// hankyeol-dev.

import Foundation

enum RepositoryErrors : Error {
   case error(message: String)
   
   var errorMessage: String {
      switch self {
      case let .error(message):
         return message
      }
   }
}
