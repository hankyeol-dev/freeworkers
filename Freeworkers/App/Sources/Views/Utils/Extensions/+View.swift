// hankyeol-dev.

import SwiftUI

extension View {
   func displayFWToastView(toast: Binding<FWToast.FWToastType?>) -> some View {
      self.modifier(FWToastModifier(toast: toast))
   }
   
   func fwTextFieldLabelStyle(
      foregroundBinder : Binding<Bool>,
      primary : Color,
      secondary : Color
   ) -> some View {
      self.modifier(FWTextFieldLabelStyle(foregroundBinder: foregroundBinder,
                                          primary: primary,
                                          secondary: secondary))
   }
   
   func fwNavigationBackStyle(_ title : String, _ popAction : @escaping () -> Void) -> some View {
      self.modifier(FWNavigationBackBarStyle(title : title, popAction: popAction))
   }
}
