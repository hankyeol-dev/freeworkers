// hankyeol-dev.

import UIKit
import CryptoKit

public protocol FilemangerProviderType {
   func getImage(_ path: String) async throws -> UIImage?
   func saveImage(_ path: String, image: UIImage) async throws
   func removeAllExpired() async
}

public final actor FilemanagerProvider : FilemangerProviderType {
   private let directoryURL : URL
   
   public init() {
      self.directoryURL = FileManager.default.urls(
         for: .cachesDirectory,
         in: .userDomainMask
      )[0].appending(path: FrameworkEnvironment.filemanagerPathKey)
      
      Task {
         await createFileDirectory()
         await removeAllExpired()
      }
   }
   
   public func getImage(_ path: String) async throws -> UIImage? {
      let fileURL = cacheFileURL(path)
      guard FileManager.default.fileExists(atPath: fileURL.path()) else { return nil }
      
      return UIImage(data: try Data(contentsOf: fileURL))
   }
   
   public func saveImage(_ path: String, image: UIImage) async throws {
      let imageObject : ImageObject = .init(image: image, expireType: .day(60)) // 만료 60일
      let data = imageObject.getImage().jpegData(compressionQuality: 0.3)
      try data?.write(to: cacheFileURL(path))

      let fileAttribute : [FileAttributeKey : Any] = [
         .modificationDate : imageObject.getEstimateExpire()
      ]
      let fileURL = cacheFileURL(path)
      try FileManager.default.setAttributes(fileAttribute, ofItemAtPath: fileURL.path())
   }
   
   public func removeAllExpired() {
      let urls = cacheAllFileURLs()
      if !urls.isEmpty {
         let expiredList = urls.filter { url in
            do {
               let attribute = try FileManager.default.attributesOfItem(atPath: url.path())
               if let expired = attribute[.modificationDate] as? Date {
                  return expired.timeIntervalSince(Date()) <= 0
               }
            } catch {
               return false
            }
            return false
         }
         
         for expiredURL in expiredList {
            try? FileManager.default.removeItem(at: expiredURL)
         }
      }
   }
}

extension FilemanagerProvider {
   private func createFileDirectory() {
      guard !FileManager.default.fileExists(atPath: directoryURL.path()) else { return }
      try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
   }
   
   private func cacheFileURL(_ path: String) -> URL {
      return directoryURL.appending(path: path, directoryHint: .notDirectory)
   }
   
   private func cacheAllFileURLs() -> [URL] {
      guard let enumrator = FileManager.default.enumerator(
         at: directoryURL,
         includingPropertiesForKeys: [.contentModificationDateKey],
         options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
      )
      else { return [] }
      guard let urls = enumrator.allObjects as? [URL] else { return [] }
      return urls
   }
   
   private func removeAllImageObject() {
      try? FileManager.default.removeItem(at: directoryURL)
   }
}
