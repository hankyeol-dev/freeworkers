// hankyeol-dev.

import Foundation

struct PaymentInputType : Encodable {
   let imp_uid : String
   let merchant_uid : String
}

struct PaymentOutputType : Decodable {
   let billing_id : String
   let merchant_uid : String
   let buyer_id : String
   let productName : String
   let price : Int
   let sesacCoin : Int
   let paidAt : String
 }

struct PaymentInputItem {
   let paymentAmount : String
   let paymentItem : String
   let paymentBuyer : String
   let merchantId : String = "ios_\(AppEnvironment.secret)_\(Int(Date().timeIntervalSince1970))"
}
