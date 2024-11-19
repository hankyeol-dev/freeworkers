// hankyeol-dev.

import UIKit

final class ImageObject {
   private let image : UIImage
   private let expireType : ImageExpireType
   private var estimateExpire : Date
   
   var isExpired : Bool { return estimateExpire.timeIntervalSince(Date()) <= 0 }
   
   init(image: UIImage, expireType: ImageExpireType) {
      self.image = image
      self.expireType = expireType
      self.estimateExpire = expireType.estimateExpire()
   }
   
   func getImage() -> UIImage { return image }
   func getEstimateExpire() -> Date { return estimateExpire }
}
