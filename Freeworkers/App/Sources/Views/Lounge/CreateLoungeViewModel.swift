// hankyeol-dev.

import Foundation
import Combine
import _PhotosUI_SwiftUI

final class CreateLoungeViewModel : ViewModelType {
   private let diContainer : DIContainer
   
   var store: Set<AnyCancellable> = .init()
   var createLoungeSuccessHandler: (() -> Void)?
   
   init(diContainer : DIContainer, handler : @escaping () -> Void) {
      self.diContainer = diContainer
      self.createLoungeSuccessHandler = handler
   }
   
   enum Action {
      case validRoungeName(name : String)
      case validCanCreate
      case setRoungeImage(items : [PhotosPickerItem])
      case createRounge
   }
   
   @Published var roungeNameFieldText : String = ""
   @Published var roungeDescriptionFieldText : String = ""
   @Published var isValidRoungeName : Bool = true
   @Published var canCreateRounge : Bool = false
   @Published var photoPickerItems : [PhotosPickerItem] = []
   @Published var selectedPhoto : (UIImage?, Data?) = (nil, nil)
   @Published var toastConfig : FWToast.FWToastType?
   
   func send(action: Action) {
      switch action {
      case let .validRoungeName(name):
         validRoungeName(name)
      case .validCanCreate:
         validCanCreate()
      case let .setRoungeImage(items):
         setRoungeImage(items)
      case .createRounge:
         Task { await createRounge() }
      }
   }
}

extension CreateLoungeViewModel {
   private func validRoungeName(_ name : String) {
      isValidRoungeName = diContainer.services.validateService.validateRoungeName(name)
      send(action: .validCanCreate)
   }
   
   private func validCanCreate() {
      canCreateRounge = (!roungeNameFieldText.isEmpty && isValidRoungeName && selectedPhoto.1 != nil)
   }
   
   private func setRoungeImage(_ items: [PhotosPickerItem])  {
      for item in items {
         item.loadTransferable(type: Data.self) { [weak self] result in
            switch result {
            case let .success(data):
               if let data, let uiImage = UIImage(data: data) {
                  DispatchQueue.main.async {
                     self?.selectedPhoto = (uiImage, uiImage.jpegData(compressionQuality: 0.2))
                     self?.send(action: .validCanCreate)
                  }
               }
            case .failure:
               DispatchQueue.main.async {
                  self?.toastConfig = .error(message: errorText.ERROR_SELECT_PHOTO, duration: 1.5)
               }
            }
         }
      }
   }
   
   private func createRounge() async {
      if canCreateRounge && isValidRoungeName, let imageData = selectedPhoto.1 {
         let input: CreateLoungeInput = .init(name: roungeNameFieldText,
                                                 image: [imageData],
                                                 description: roungeDescriptionFieldText)
         await diContainer.services.workspaceService.createWorkspace(input: input)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errors in
               if case let .failure(errors) = errors {
                  self?.toastConfig = .error(message: errors.errorMessage, duration: 1.5)
               }
            } receiveValue: { [weak self] createSuccess in
               if createSuccess {
                  self?.createLoungeSuccessHandler?()
               }
            }
            .store(in: &store)
      }
   }
}
