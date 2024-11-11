// hankyeol-dev.

import SwiftUI

struct FWFlipedHeader : View {
   @Binding var toggleCondition : Bool
   let HeaderTitle : String
   var action : () -> Void
   
   var body: some View {
      HStack {
         Text(HeaderTitle)
            .font(.fwT2)
         Spacer()
         Button {
            withAnimation(.easeInOut) {
               action()
            }
         } label: {
            withAnimation(.easeInOut) {
               Image(systemName: "chevron.up")
                  .resizable()
                  .frame(width: 10.0, height: 6.0)
                  .rotationEffect(
                     Angle(degrees: toggleCondition ? 180 : 0)
                  )
                  .foregroundStyle(.black)
            }
         }
      }
      .padding(.horizontal, 20.0)
   }
}
