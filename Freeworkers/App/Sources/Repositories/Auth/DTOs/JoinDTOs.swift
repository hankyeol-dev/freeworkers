// hankyeol-dev.

import Foundation

struct JoinInputType : Codable {
   let email: String
   let password: String
   let nickname: String
   let phone: String?
   let deviceToken: String?
}

struct CommonAuthOutputType : Decodable {
   let user_id: String
   let email: String
   let nickname: String
   let profileImage: String?
   let phone: String?
   let provider: String?
   let createdAt: String
   let token: TokenOutputType
}
