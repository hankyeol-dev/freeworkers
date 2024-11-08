// hankyeol-dev.

import SwiftUI
import PhotosUI

struct CreateLoungeView : View {
   @StateObject var viewModel : CreateLoungeViewModel
   
   var body: some View {
      VStack(alignment : .leading, spacing : 20.0) {
         Spacer.height(30.0)
         
         VStack(alignment : .center) {
            PhotosPicker(
               selection: $viewModel.photoPickerItems,
               maxSelectionCount: 1,
               selectionBehavior: .default,
               matching: .images
            ) {
               Image(uiImage: viewModel.selectedPhoto.0 ?? UIImage(resource: .photoIcon))
                  .resizable()
                  .frame(width: 100.0, height: 100.0)
                  .scaledToFill()
                  .clipShape(RoundedRectangle(cornerRadius: 10.0))
            }
            .onChange(of: viewModel.photoPickerItems) { _, newItems in
               viewModel.send(action: .setRoungeImage(items: newItems))
            }
         }
         .frame(maxWidth: .infinity)
         .padding(.bottom, 15.0)
         
         
         VStack {
            Text(workspaceTitle.CREATE_ROUNGE_NAME_LABEL)
               .fwTextFieldLabelStyle(foregroundBinder: $viewModel.isValidRoungeName,
                                      primary: .black,
                                      secondary: .error)
               .onChange(of: viewModel.roungeNameFieldText) { _, newValue in
                  viewModel.send(action: .validRoungeName(name: newValue))
               }
            TextField(placeholderText.CREATE_ROUNGE_NAME, text: $viewModel.roungeNameFieldText)
               .textFieldStyle(FWTextFieldStyle(keyboardType: .default))
         }
         
         VStack {
            Text(workspaceTitle.CREATE_ROUNGE_DESCRIPTION_LABEL)
               .fwTextFieldLabelStyle(foregroundBinder: $viewModel.isValidRoungeName,
                                      primary: .black,
                                      secondary: .black)
            TextField(placeholderText.CREATE_ROUNGE_DESCRIPTION,
                      text: $viewModel.roungeDescriptionFieldText)
            .textFieldStyle(FWTextFieldStyle(keyboardType: .default))
         }
         .padding(.bottom, 5.0)
         
         FWRoundedButton(
            title: buttonTitle.CREATE_ROUNGE,
            height: 50.0,
            background: !viewModel.canCreateRounge ? .gray : Color.primary,
            disabled: !viewModel.canCreateRounge
         ) {
            viewModel.send(action: .createRounge)
         }
         
         Spacer()
      }
      .padding(.horizontal, 24.0)
      .background(Color.bg)
      .displayFWToastView(toast: $viewModel.toastConfig)
   }
}
