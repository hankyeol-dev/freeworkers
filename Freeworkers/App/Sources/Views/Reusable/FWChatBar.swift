// hankyeol-dev.

import UIKit
import SwiftUI
import PhotosUI

struct FWChatBar : View {
   @State private var toastConfig : FWToast.FWToastType?
   @State private var textViewHeight : CGFloat = 40.0
   
   @Binding var photoSelection : [PhotosPickerItem]
   @Binding var photoDatas : [(UIImage, Data)]
   @Binding var chatText : String
   @FocusState var chatTextViewFocus : Bool
   
   private let placeholder : String = placeholderText.CHATBAR
   
   let sendAction : () -> Void
   
   var body: some View {
      HStack(alignment: .bottom, spacing: 10.0) {
         PhotosPicker(
            selection: $photoSelection,
            maxSelectionCount: 5,
            selectionBehavior: .default,
            matching: .images
         ) {
            Circle()
               .fill(Color.bg)
               .frame(width: 30.0, height: 30.0)
               .overlay {
                  Image(systemName: "plus")
                     .resizable()
                     .font(.fwT1)
                     .frame(width: 15.0, height: 15.0)
                     .foregroundStyle(.black)
               }
         }
         .onTapGesture {
            chatTextViewFocus = false
         }
         .onChange(of: photoSelection) { _, newValue in
            setImage(newValue)
         }
         
         FWChatTextView(text: $chatText, height: $textViewHeight, placeholder: placeholder)
            .focused($chatTextViewFocus)
            .tint(Color.black)
            .padding(.horizontal, 15.0)
            .background(Color.bg)
            .clipShape(RoundedRectangle(cornerRadius: 12.0))
            .frame(minHeight: textViewHeight, maxHeight: .infinity)
         
         Button {
            chatTextViewFocus = false
            sendAction()
         } label: {
            Circle()
               .fill(Color.bg)
               .frame(width: 30.0, height: 30.0)
               .overlay {
                  Image(systemName: "arrow.up.circle.fill")
                     .resizable()
                     .font(.fwT1)
                     .frame(width: 15.0, height: 15.0)
                     .foregroundStyle(
                        (chatText.isEmpty && photoSelection.isEmpty) || chatText == placeholder
                        ? .gray : .black
                     )
               }
         }
         .disabled((chatText.isEmpty && photoSelection.isEmpty) || chatText == placeholder)
      }
      .displayFWToastView(toast: $toastConfig)
      .padding(.horizontal, 10.0)
      .frame(height: 30.0)
      .frame(minHeight: textViewHeight + 20.0)
   }
   
   @MainActor
   private func setImage(_ photos : [PhotosPickerItem]) {
      photoDatas = []
      for photo in photos {
         photo.loadTransferable(type: Data.self) { transferResult in
            switch transferResult {
            case let .success(data):
               if let data,
                  let uiImage = UIImage(data: data),
                  let imageData = uiImage.downscaleTOjpegData(maxBytes: 1_000_000) {
                  DispatchQueue.main.async {
                     photoDatas.append((uiImage, imageData))
                  }
               }
            case .failure:
               toastConfig = .error(message: errorText.ERROR_SELECT_PHOTO, duration: 1.0)
            }
         }
      }
   }
}
