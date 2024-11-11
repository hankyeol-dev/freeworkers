// hankyeol-dev.

import SwiftUI

struct FWSectionDivider : View {
   private var height : CGFloat
   
   init(height: CGFloat = 10.0) {
      self.height = height
   }
   
   var body: some View {
      Rectangle()
         .fill(Color.bg)
         .frame(height: height)
         .frame(maxWidth: .infinity)
   }
}
