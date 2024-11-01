// hankyeol-dev.

import SwiftUI

struct FWRoundedButton: View {
   private var title: String
   private var font: Font
   private var width: CGFloat
   private var height: CGFloat
   private var foreground: Color
   private var background: Color
   private var disabled: Bool
   private var action: () -> Void
   
   init(title: String, 
        font: Font = .fwT2,
        width: CGFloat = 345.0,
        height: CGFloat = 44.0,
        foreground: Color = .white,
        background: Color = .black,
        disabled: Bool = false,
        action: @escaping () -> Void
   ) {
      self.title = title
      self.font = font
      self.width = width
      self.height = height
      self.foreground = foreground
      self.background = background
      self.disabled = disabled
      self.action = action
   }
   
   var body: some View {
      Button {
         action()
      } label: {
         RoundedRectangle(cornerRadius: 8.0, style: .continuous)
            .fill(background)
            .frame(width: width, height: height)
            .overlay {
               Text(title)
                  .foregroundStyle(foreground)
                  .font(font)
            }
      }
      .disabled(disabled)
   }
}
