// hankyeol-dev.

import UIKit

public protocol MemoryCacheProviderType {
   func getImage(_ sort: String) -> UIImage?
   func saveImage(_ sort: String, image: UIImage)
}

public final class MemoryCacheProvider: MemoryCacheProviderType {
   public init() {}
   
   private var cache = NSCache<NSString, UIImage>() // key-value
   
   public func getImage(_ sort: String) -> UIImage? {
      cache.object(forKey: NSString(string: sort))
   }
   
   public func saveImage(_ sort: String, image: UIImage) {
      cache.setObject(image, forKey: NSString(string: sort))
   }
}
