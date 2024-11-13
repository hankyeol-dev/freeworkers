// hankyeol-dev.

import SwiftUI
import PhotosUI

struct ChannelView : View {
   @StateObject var viewModel : ChannelViewModel
   @FocusState private var chatTextViewFocus : Bool
   
   var body: some View {
      VStack {
         // TODO: Chatting View
         chattingView
         Spacer()
         chattingBar
            .padding(.bottom, 1.0)
      }
      .task {
         viewModel.send(action: .enterChannel)
      }
      .onDisappear {
         viewModel.send(action: .moveOutFromChannel)
      }
      .toolbar {
         ToolbarItem(placement: .topBarTrailing) {
            Button {
               viewModel.send(action: .channelSettingButtonTapped)
            } label: {
               Image(.menuDotIcon)
                  .resizable()
                  .frame(width: 15.0, height: 10.0)
                  .foregroundStyle(.black)
            }
         }
      }
      .navigationDestination(for: NavigationDestination.self) { destination in
         RoutingView(destination: destination)
      }
      .overlay {
         if viewModel.isDisplayPhotoViewer, let chat = viewModel.selectedChat {
            FWImageViewer(files: chat.files,
                          selectedImageIndex: $viewModel.photoViewerIndex) {
               viewModel.send(action: .togglePhotoViewer)
            }
         }
      }
   }
   
   @ViewBuilder
   var chattingView : some View {
      ScrollViewReader { proxy in
         ScrollView {
            ForEach(viewModel.chats.indices, id: \.self) { index in
               LazyVStack {
                  FWChat(chat: viewModel.chats[index]) { selectedImageIndex in
                     viewModel.send(action: .selectChatImage(chatIndex: index,
                                                             imageIndex: selectedImageIndex))
                  }
                  .id(viewModel.chats[index].id)
               }
               .padding(.horizontal, 15.0)
               .padding(.top, 10.0)
            }
         }
         .onChange(of: chatTextViewFocus) { _, newValue in
            if newValue {
               print(newValue)
               proxy.scrollTo(viewModel.chats.last?.id, anchor: .bottom)
            }
         }
         .onChange(of: viewModel.chats.last) { _, newValue in
            proxy.scrollTo(newValue?.id, anchor: .bottom)
         }
      }
      .onTapGesture {
         chatTextViewFocus = false
      }
   }
   
   @ViewBuilder
   var chattingBar : some View {
      VStack {
         if !viewModel.photoDatas.isEmpty {
            HStack {
               ForEach(viewModel.photoDatas, id:\.0.self) { photo in
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
                           viewModel.send(action: .deSelectPhoto(data: photo.0))
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
            photoSelection : $viewModel.photoSelection,
            photoDatas: $viewModel.photoDatas,
            chatText: $viewModel.chatText,
            chatTextViewFocus: _chatTextViewFocus,
            sendAction: { viewModel.send(action: .sendChannelChat) }
         )
      }
      .frame(maxWidth: .infinity)
   }
}
