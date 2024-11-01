// hankyeol-dev.

import Foundation

struct TokenOutputType : Decodable {
   let accessToken : String
   let refreshToken : String
}

struct TokenRefreshOutputType : Decodable {
   let accessToken : String
}
