// hankyeol-dev.

import Foundation

struct LoginInputType : Encodable {
   let email: String
   let password: String
   let deviceToken: String? = nil
}
