// hankyeol-dev.

import SwiftUI

struct FWTextFieldLabelStyle : ViewModifier {
   @Binding var foregroundBinder : Bool
   let primary : Color
   let secondary : Color
   
   func body(content: Content) -> some View {
      content
         .font(.fwT2)
         .foregroundStyle(foregroundBinder ? primary : secondary)
         .frame(maxWidth: .infinity, alignment: .leading)
   }
}
