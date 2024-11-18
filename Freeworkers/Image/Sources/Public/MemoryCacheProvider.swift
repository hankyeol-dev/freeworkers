// hankyeol-dev.

import UIKit

public protocol MemoryCacheProviderType {
   func getImage(_ path: String) -> UIImage?
   func saveImage(_ path: String, image: UIImage)
}

public final class MemoryCacheProvider: MemoryCacheProviderType {
   public init() {}
   
   private var cache = NSCache<NSString, UIImage>() // key-value
   
   public func getImage(_ path: String) -> UIImage? {
      cache.object(forKey: NSString(string: path))
   }
   
   public func saveImage(_ path: String, image: UIImage) {
      cache.setObject(image, forKey: NSString(string: path))
   }
}
