// hankyeol-dev.

import UIKit
import Combine

import FreeworkersNetworkKit

public protocol ImageCacheProviderType {
   func getImage(_ sort : String, endpoint : EndpointProtocol, refreshHandler : @escaping () async throws -> Data?) async -> UIImage?
}

public struct ImageProvider : ImageCacheProviderType {
   private let filemanagerProvider : FilemangerProviderType
   private let memoryCacheProvider : MemoryCacheProviderType
   
   public init(filemanagerProvider: FilemangerProviderType, memoryCacheProvider: MemoryCacheProviderType) {
      self.filemanagerProvider = filemanagerProvider
      self.memoryCacheProvider = memoryCacheProvider
   }
   
   public func getImage(
      _ sort : String,
      endpoint : EndpointProtocol,
      refreshHandler : @escaping() async throws -> Data?
   ) async -> UIImage? {
      // 1. memory storage check
      if let outputFromMemory = checkFromMemoryCache(sort) {
         return outputFromMemory
      }
      
      // 2. disk storage check
      if let outputFromDisk = checkFromeDiskCache(sort) {
         // 2-1. memory에는 없다는 뜻이니까, 이후 활용을 위해 memory에 저장
         saveImage(sort, image: outputFromDisk, saveOnDisk: false)
         return outputFromDisk
      }
      
      // 3. url session -> memory, disk 저장 -> 활용
      if let data = await requestFromServer(endpoint: endpoint, refreshHandler: refreshHandler) {
         return UIImage(data: data)
      }
         
      return nil
   }
}

extension ImageProvider {
   /// MemoryCache에서 이미지가 있는지 조회
   private func checkFromMemoryCache(_ sort : String) -> UIImage? {
      return memoryCacheProvider.getImage(sort)
   }
   
   /// DiskCache에서 이미지가 있는지 조회
   private func checkFromeDiskCache(_ sort : String) -> UIImage? {
      do {
         return try filemanagerProvider.getImage(sort)
      } catch {
         return nil
      }
   }
   
   private func requestFromServer(
      endpoint : EndpointProtocol,
      refreshHandler : @escaping() async throws -> Data?
   ) async -> Data? {
      do {
         return try await NetworkService.requestImage(endpoint: endpoint)
      } catch NetworkErrors.error(message: .E05) {
         return try! await refreshHandler()
      } catch {
         return nil
      }
   }
   
   /// 이미지를 캐시에 저장해주는 로직
   private func saveImage(_ sort : String, image : UIImage, saveOnDisk : Bool) {
      memoryCacheProvider.saveImage(sort, image: image)
      if saveOnDisk { try? filemanagerProvider.saveImage(sort, image: image) }
   }
}

