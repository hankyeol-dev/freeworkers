// hankyeol-dev.

import SwiftUI

struct FWSectionDivider : View {
   private var color : Color
   private var height : CGFloat
   
   init(color : Color = Color.bg, height: CGFloat = 10.0) {
      self.color = color
      self.height = height
   }
   
   var body: some View {
      Rectangle()
         .fill(color)
         .frame(height: height)
         .frame(maxWidth: .infinity)
   }
}
