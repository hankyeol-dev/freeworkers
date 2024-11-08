// hankyeol-dev.

import SwiftUI

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
