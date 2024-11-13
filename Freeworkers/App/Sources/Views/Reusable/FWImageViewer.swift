// hankyeol-dev.

import SwiftUI

struct FWImageViewer : View {
   let files : [String]
   @Binding var selectedImageIndex : Int
   var displayHandler : () -> Void
   
   @State private var imageOffset : CGSize = .zero
   @GestureState private var dragOffset : CGSize = .zero
   @State private var imageScale : CGFloat = 1.0
   
   var body: some View {
      ZStack {
         Color.black.opacity(0.8)
         TabView(selection : $selectedImageIndex) {
            ForEach(files.indices, id:\.self) { index in
               FWImage(imagePath: files[index])
                  .aspectRatio(contentMode: .fit)
                  .tag(index)
                  .scaleEffect(
                     selectedImageIndex == index
                     ? imageScale > 1.0
                     ? imageScale : 1.0
                     : 1.0
                  )
                  .offset(y : imageOffset.height)
                  .gesture(
                     MagnificationGesture().onChanged { zoomValue in
                        imageScale = zoomValue
                     }.onEnded { _ in
                        withAnimation(.spring) { imageScale = 1.0 }
                     }.simultaneously(
                        with: TapGesture(count: 2).onEnded { _ in
                           withAnimation(.spring) {
                              imageScale = imageScale > 1.0 ? 1.0 : 2.5
                           }
                        }
                     )
                  )
            }
         }
         .tabViewStyle(.page(indexDisplayMode: .always))
         .overlay (
            Button {
               withAnimation {
                  displayHandler()
               }
            } label: {
               Circle()
                  .fill(Color.bg)
                  .frame(width: 32.0, height: 32.0)
                  .overlay {
                     Image(systemName: "xmark")
                        .font(.fwRegular)
                        .foregroundStyle(.black)
                  }
            }.padding(.top, 15.0).padding(.trailing, 15.0),
            alignment: .topTrailing
         )
      }
      .gesture(
         DragGesture().updating($dragOffset) { dragValue, movingValue, _ in
            movingValue = dragValue.translation
            DispatchQueue.main.async { imageOffset = dragOffset }
         }.onEnded { dragValue in
            DispatchQueue.main.async {
               var dragHeight = dragValue.translation.height
               
               if dragHeight < 0 { dragHeight = -dragHeight }
               if dragHeight <= 200 {
                  imageOffset = .zero
               } else {
                  displayHandler()
                  imageOffset = .zero
               }
            }
         }
      )
      .transition(.move(edge : .bottom))
   }
}
