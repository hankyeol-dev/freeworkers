// hankyeol-dev.

import UIKit
import Combine

protocol ImageServiceType {
   func getImage(_ imagePath : String) async -> AnyPublisher<UIImage?, Never>
}

struct ImageService : ImageServiceType {
   private let imageRepository : ImageRepositoryType
   
   init(imageRepository: ImageRepositoryType) {
      self.imageRepository = imageRepository
   }
}

extension ImageService {
   func getImage(_ imagePath: String) async -> AnyPublisher<UIImage?, Never> {
      let image = await imageRepository.getImage(imagePath)
      return Future { promise in
         if let image {
            promise(.success(image))
         } else {
            promise(.success(nil))
         }
      }.eraseToAnyPublisher()
   }
}
