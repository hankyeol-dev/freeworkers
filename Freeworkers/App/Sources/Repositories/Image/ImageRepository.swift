// hankyeol-dev.

import UIKit

import FreeworkersNetworkKit
import FreeworkersImageKit

protocol ImageRepositoryType : CoreRepositoryType {
   func getImage(_ imagePath : String) async -> UIImage?
}

struct ImageRepository : ImageRepositoryType {
   private let imageProvider : ImageProvider
   
   init() {
      self.imageProvider = ImageProvider(filemanagerProvider: FilemanagerProvider(),
                                         memoryCacheProvider: MemoryCacheProvider())
   }
}

extension ImageRepository {
   func getImage(_ imagePath : String) async -> UIImage? {
      return await imageProvider.getImage(imagePath, endpoint: ImageRouter.path(input: imagePath)) {
         if await refreshToken() {
            return try await NetworkService.requestImage(endpoint: ImageRouter.path(input: imagePath))
         } else {
            return nil
         }
      }
   }
}
