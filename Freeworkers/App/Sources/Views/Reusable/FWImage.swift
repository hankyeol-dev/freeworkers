// hankyeol-dev.

import SwiftUI
import UIKit
import Combine

struct FWImage : View {
   @EnvironmentObject var diConatiner : DIContainer // TODO: background issue 해결하기
   let imagePath : String
   let placeholderImageName : String
   
   init(imagePath: String, placeholderImageName: String? = nil) {
      self.imagePath = imagePath
      self.placeholderImageName = placeholderImageName ?? ""
   }
   
   var body: some View {
      FWImageInner(viewModel: .init(diContainer: diConatiner, imagePath: imagePath),
                   placeholderImageName: placeholderImageName).id(imagePath)
   }
}

struct FWImageInner : View {
   @StateObject var viewModel : ViewModel
   let placeholderImageName : String
   private var placeholderImage : UIImage {
      UIImage(named: placeholderImageName) ?? UIImage(resource: .home)
   }
   
   var body: some View {
      Image(uiImage: viewModel.loadedImage ?? placeholderImage)
         .resizable()
         .aspectRatio(contentMode: .fill)
         .onAppear {
            viewModel.send(action: .fetchImage)
         }
   }
}

extension FWImageInner {
   final class ViewModel : ViewModelType {
      private let diContainer : DIContainer
      private let imagePath : String

      var store: Set<AnyCancellable> = .init()
      var isLoadingOrFetched : Bool {
         return isLoading || loadedImage != nil
      }
      
      init(diContainer : DIContainer, imagePath : String) {
         self.diContainer = diContainer
         self.imagePath = imagePath
      }

      @Published var isLoading : Bool = false
      @Published var loadedImage : UIImage?

      enum Action {
         case fetchImage
      }

      func send(action: Action) {
         if case .fetchImage = action {
            Task { await fetchImage() }
         }
      }
      
      private func fetchImage() async {
         isLoading = true
         await diContainer.services.imageService.getImage(imagePath)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { fetchImageOutput in
               Task {
                  await MainActor.run { [weak self] in
                     guard let self else { return }
                     isLoading = false
                     loadedImage = fetchImageOutput
                  }
               }
            }
            .store(in: &store)
      }
   }
}
