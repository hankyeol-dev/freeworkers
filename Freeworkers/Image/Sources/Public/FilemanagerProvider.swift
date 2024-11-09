// hankyeol-dev.

import UIKit
import CryptoKit

public protocol FilemangerProviderType {
   func getImage(_ sort: String) throws -> UIImage?
   func saveImage(_ sort: String, image: UIImage) throws
}

public final class FilemanagerProvider : FilemangerProviderType {
   private let fileManager : FileManager
   private let directoryURL : URL
   
   public init(fileManager : FileManager = .default) {
      self.fileManager = fileManager
      self.directoryURL = fileManager.urls(
         for: .cachesDirectory,
         in: .userDomainMask
      )[0].appending(path: FrameworkEnvironment.filemanagerPathKey)
      
      createFileDirectory()
   }
   
   public func getImage(_ sort: String) throws -> UIImage? {
      let fileURL = cacheFileURL(sort)
      guard fileManager.fileExists(atPath: fileURL.path()) else { return nil }
      
      return UIImage(data: try Data(contentsOf: fileURL))
   }
   
   public func saveImage(_ sort: String, image: UIImage) throws {
      let data = image.jpegData(compressionQuality: 0.3)
      try data?.write(to: cacheFileURL(sort))
   }
}

extension FilemanagerProvider {
   private func createFileDirectory() {
      guard !fileManager.fileExists(atPath: directoryURL.path()) else { return }
      try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
   }
   
   private func cacheFileURL(_ sort: String) -> URL {
      let hashingName = sha256(sort)
      return directoryURL.appending(path: hashingName, directoryHint: .notDirectory)
   }
   
   private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      return hashedData.compactMap { String(format: "%02x", $0) }.joined()
   }
}
