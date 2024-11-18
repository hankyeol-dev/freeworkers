// hankyeol-dev.

import UIKit
import CryptoKit

public protocol FilemangerProviderType {
   func getImage(_ path: String) throws -> UIImage?
   func saveImage(_ path: String, image: UIImage) throws
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
   
   public func getImage(_ path: String) throws -> UIImage? {
      let fileURL = cacheFileURL(path)
      guard fileManager.fileExists(atPath: fileURL.path()) else { return nil }
      
      return UIImage(data: try Data(contentsOf: fileURL))
   }
   
   public func saveImage(_ path: String, image: UIImage) throws {
      let data = image.jpegData(compressionQuality: 0.3)
      try data?.write(to: cacheFileURL(path))
   }
}

extension FilemanagerProvider {
   private func createFileDirectory() {
      guard !fileManager.fileExists(atPath: directoryURL.path()) else { return }
      try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
   }
   
   private func cacheFileURL(_ path: String) -> URL {
      return directoryURL.appending(path: path, directoryHint: .notDirectory)
   }
}
