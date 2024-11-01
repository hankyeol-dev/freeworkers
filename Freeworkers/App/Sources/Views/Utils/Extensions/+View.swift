// hankyeol-dev.

import SwiftUI

extension View {
   func displayFWToastView(toast: Binding<FWToast.FWToastType?>) -> some View {
      self.modifier(FWToastModifier(toast: toast))
   }
}

struct FWTextFieldStyle: TextFieldStyle {
   var keyboardType : UIKeyboardType = .default
   
   func _body(configuration: TextField<Self._Label>) -> some View {
      configuration
         .padding()
         .foregroundStyle(.black)
         .background(.white)
         .tint(.black)
         .font(.fwRegular)
         .clipShape(RoundedRectangle(cornerRadius: 8.0))
         .textInputAutocapitalization(.never)
   }
}
