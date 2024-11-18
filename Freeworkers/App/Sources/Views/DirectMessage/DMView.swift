// hankyeol-dev.

import SwiftUI

struct DMView : View {
   @EnvironmentObject var diContainer : DIContainer
   @EnvironmentObject var envContainer : EnvironmentContainer
   
   @StateObject var viewModel : DMViewModel
   @FocusState private var chatFocus : Bool
      
   var body: some View {
      VStack {
         chattingView
         Spacer()
         chattingBar
            .padding(.bottom, 1.0)
      }
      .overlay {
         if viewModel.displayPhotoViewer, let photoViewerChat = viewModel.photoViewerChat {
            FWImageViewer(
               files: photoViewerChat.files,
               selectedImageIndex: $viewModel.photoViewerIndex) {
                  chatFocus = false
                  viewModel.send(action: .displayPhotoViewer)
               }
         }
      }
      .task {
         if !envContainer.hideTab { envContainer.toggleTab() }
         viewModel.send(action: .didLoad)
      }
      .onDisappear {
         viewModel.send(action: .didDisappear)
      }
      .toolbar(.hidden, for: .tabBar)
      .toolbar(viewModel.displayPhotoViewer ? .hidden : .visible, for: .navigationBar)
   }
   
   @ViewBuilder
   var chattingView : some View {
      ScrollViewReader { proxy in
         ScrollView(.vertical) {
            let chats = viewModel.chats
            ForEach(chats.indices, id:\.self) { index in
               LazyVStack {
                  FWChat(chat: chats[index]) { photoIndex in
                     viewModel.send(action: .tapChatImage(chatIndex: index, photoIndex: photoIndex))
                  } profileTapHandler: { _ in }.id(chats[index].id)
               }
               .padding(.horizontal, 15.0)
               .padding(.top, 10.0)
            }
         }
         .onChange(of: viewModel.chats.last) { _, newValue in
            proxy.scrollTo(newValue?.id, anchor: .bottomTrailing)
         }
         .onChange(of: chatFocus) {
            if chatFocus { proxy.scrollTo(viewModel.chats.last?.id, anchor: .bottom) }
         }
      }
      .onTapGesture {
         chatFocus = false
      }
   }
   
   @ViewBuilder
   var chattingBar : some View {
      VStack {
         if !viewModel.photoDatas.isEmpty {
            HStack {
               ForEach(viewModel.photoDatas, id: \.0.self) { photo in
                  ZStack {
                     Image(uiImage: photo.0)
                        .resizable()
                        .frame(width: 30.0, height: 30.0)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                     
                     Circle()
                        .fill(Color.bg)
                        .frame(width: 15.0, height: 15.0)
                        .overlay {
                           Image(systemName: "xmark")
                              .resizable()
                              .frame(width: 8.0, height: 8.0)
                              .font(.fwRegular)
                              .foregroundStyle(.black)
                        }
                        .padding(.leading, 30.0)
                        .padding(.bottom, 30.0)
                        .onTapGesture {
                           viewModel.send(action: .deselectPhoto(photo: photo.0))
                        }
                  }
               }
            }
            .frame(height: 40.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10.0)
            .padding(.top, 10.0)
            .background(Color.bg.opacity(0.5))
         }
         
         FWChatBar(
            photoSelection: $viewModel.photoSelection,
            photoDatas: $viewModel.photoDatas,
            chatText: $viewModel.chatText,
            chatTextViewFocus: _chatFocus,
            sendAction: { viewModel.send(action: .sendDM) })
      }
      .frame(maxWidth: .infinity)
   }
}
