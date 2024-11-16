// hankyeol-dev.

import SwiftUI

struct FWCentreConfirm : View {
   
   private let header : String
   private let content : [String]
   private let cancelTitle : String
   private let confirmTitle : String
   private let isConfirm : Bool
   private let cancelAction : () -> Void
   private let confirmAction : () -> Void
   
   init(
      header: String,
      content: [String],
      cancelTitle : String,
      confirmTitle : String,
      isConfirm : Bool = true,
      cancelAction : @escaping () -> Void,
      confirmAction: @escaping () -> Void) {
         self.header = header
         self.content = content
         self.cancelTitle = cancelTitle
         self.confirmTitle = confirmTitle
         self.isConfirm = isConfirm
         self.cancelAction = cancelAction
         self.confirmAction = confirmAction
   }
   
   var body : some View {
      ZStack {
         Color.black.opacity(0.5)
            .onTapGesture {
               cancelAction()
            }
         
         VStack(alignment : .center, spacing : 20.0) {
            Text(header)
               .font(.fwT2)
               .foregroundStyle(.black)
            
            LazyVStack(alignment: .leading, spacing: 8.0) {
               ForEach(content, id:\.self) { text in
                  Text(text)
                     .font(.fwRegular)
                     .foregroundStyle(.gray.opacity(1.5))
               }
            }
            
            HStack(alignment : .center, spacing: 10.0) {
               FWRoundedButton(
                  title: cancelTitle,
                  width : isConfirm ? 150.0 : 300.0,
                  foreground: .white,
                  background: .gray.opacity(1.5)
               ) {
                  cancelAction()
               }
               
               if isConfirm {
                  FWRoundedButton(
                     title: confirmTitle,
                     width : 150.0
                  ) {
                     confirmAction()
                  }
               }
            }
         }
         .padding()
         .frame(maxWidth: 330.0)
         .background(.white)
         .clipShape(RoundedRectangle(cornerRadius: 10.0))
         .transition(.move(edge : .bottom))
      }
      .ignoresSafeArea()
   }
}
