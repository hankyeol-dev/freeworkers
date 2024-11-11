// hankyeol-dev.

import SwiftUI

struct FWNavigationBackBarStyle : ViewModifier {
   private let title : String
   private var popAction : () -> Void
   
   init(title : String, popAction: @escaping () -> Void) {
      self.title = title
      self.popAction = popAction
   }
   
   func body(content: Content) -> some View {
      content
         .navigationTitle(title)
         .navigationBarTitleDisplayMode(.inline)
         .navigationBarBackButtonHidden()
         .toolbar {
            ToolbarItem(id: "backToChannel",
                        placement: .topBarLeading) {
               Button {
                  popAction()
               } label: {
                  Image(systemName: "chevron.left")
                     .resizable()
                     .frame(width: 6.0, height: 10.0)
                     .foregroundStyle(.black)
               }
            }
         }
         .toolbarBackground(Color.bg, for: .navigationBar)
         .toolbarBackground(.visible, for: .navigationBar)
   }
}
