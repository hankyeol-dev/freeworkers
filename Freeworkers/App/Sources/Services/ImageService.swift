// hankyeol-dev.

import UIKit
import Combine

protocol ImageServiceType {
   func getImage(_ imagePath : String) async -> UIImage?
}

struct ImageService : ImageServiceType {
   private let imageRepository : ImageRepositoryType
   
   init(imageRepository: ImageRepositoryType) {
      self.imageRepository = imageRepository
   }
}

extension ImageService {
   func getImage(_ imagePath: String) async -> UIImage? {
      if imagePath == "/" { return nil }
      return await imageRepository.getImage(imagePath)
   }
}
