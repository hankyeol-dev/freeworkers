// hankyeol-dev.

import SwiftUI
import UIKit

struct FWImage : View {
   @EnvironmentObject var diContainer : DIContainer
   
   @State private var isLoading : Bool = false
   @State private var loadedImage : UIImage?
   
   let imagePath : String
   let placeholderImageName : String
   
   private var placeholderImage : UIImage {
      UIImage(named: placeholderImageName) ?? UIImage(systemName: "person.circle")!
   }
   
   init(imagePath: String, placeholderImageName: String? = nil) {
      self.imagePath = imagePath
      self.placeholderImageName = placeholderImageName ?? ""
   }
   
   var body: some View {
      Image(uiImage: loadedImage ?? placeholderImage)
         .resizable()
         .aspectRatio(contentMode: .fill)
         .task {
            await fetchImage()
         }
   }
   
   private func fetchImage() async {
      isLoading = true
      loadedImage = await diContainer.services.imageService.getImage(imagePath)
   }
}
