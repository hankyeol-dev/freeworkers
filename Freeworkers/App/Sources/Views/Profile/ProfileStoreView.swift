// hankyeol-dev.

import UIKit
import SwiftUI

import iamport_ios

struct ProfileStoreView: UIViewControllerRepresentable {
   let paymentInput : PaymentInputItem
   let responseHandler : (PaymentInputType) async -> Void
   
   func makeUIViewController(context: Context) -> UIViewController {
      return IamportPaymentViewController(paymentInput : paymentInput, responseHandler: responseHandler)
   }
   
   func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class IamportPaymentViewController: UIViewController {
   let paymentInput : PaymentInputItem
   let responseHandler : (PaymentInputType) async -> Void
   
   override func viewDidLoad() {
      super.viewDidLoad()
      requestIamportPayment()
   }
   
   init(paymentInput : PaymentInputItem, responseHandler: @escaping (PaymentInputType) async -> Void) {
      self.paymentInput = paymentInput
      self.responseHandler = responseHandler
      super.init(nibName: nil, bundle: nil)
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   func requestIamportPayment() {
      let userCode = AppEnvironment.storeId
      let payment = createPaymentData()
      
      Iamport.shared.payment(
         viewController: self,
         userCode: userCode, 
         payment: payment
      ) { [weak self] response in
         if let response {
            if let imp_uid = response.imp_uid, let mer_uid = response.merchant_uid {
               let input : PaymentInputType = .init(imp_uid: imp_uid, merchant_uid: mer_uid)
               Task { await self?.responseHandler(input) }
            }
         }
      }
   }
   
   func createPaymentData() -> IamportPayment {
      return IamportPayment(
         pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
         merchant_uid: paymentInput.merchantId,
         amount: paymentInput.paymentAmount).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = paymentInput.paymentItem
            $0.buyer_name = paymentInput.paymentBuyer
            $0.app_scheme = "slp"
         }
   }
}
