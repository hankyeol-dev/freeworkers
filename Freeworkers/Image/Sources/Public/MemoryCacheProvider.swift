// hankyeol-dev.

import UIKit

public protocol MemoryCacheProviderType {
   func getImage(_ path: String) async -> UIImage?
   func saveImage(_ path: String, image: UIImage) async
}

public final actor MemoryCacheProvider: MemoryCacheProviderType {
   public init() {
      Timer.scheduledTimer(withTimeInterval: 300, repeats: true) {  _ in
         Task { [weak self] in
            guard let self else { return }
            await removeEstimatedExpire()
         } // 5분에 한 번씩 메모리 캐시 확인 후 데이터 지움
      }
   }
   
   private var cache = {
      let cache = NSCache<NSString, ImageObject>()
      let totalMemory = ProcessInfo.processInfo.physicalMemory
      let costLimit = totalMemory / 4
      cache.totalCostLimit = (costLimit > Int.max) ? Int.max : Int(costLimit)
      return cache
   }()
   private var cacheKeys = Set<NSString>()
   
   public func getImage(_ path: String) -> UIImage? {
      cache.object(forKey: NSString(string: path))?.getImage()
   }
   
   public func saveImage(_ path: String, image: UIImage) {
      let imageObject : ImageObject = .init(image: image, expireType: .sec(600)) // 10분정도로 메모리 캐시 설정
      cache.setObject(imageObject, forKey: NSString(string: path))
      cacheKeys.insert(NSString(string: path))
   }
   
   private func removeAllImage() {
      cache.removeAllObjects()
      cacheKeys.removeAll()
   }
   
   private func removeEstimatedExpire() {
      for key in cacheKeys {
         guard let imageObject = cache.object(forKey: key) else {
            cacheKeys.remove(key)
            return
         }
         
         if imageObject.isExpired {
            cache.removeObject(forKey: key)
            cacheKeys.remove(key)
         }
      }
   }
}
