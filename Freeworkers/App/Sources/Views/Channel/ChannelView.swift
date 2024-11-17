// hankyeol-dev.

import SwiftUI
import PhotosUI

struct ChannelView : View {
   @EnvironmentObject var diContainer : DIContainer
   @Environment(\.scenePhase) private var scenePhase
   @StateObject var viewModel : ChannelViewModel

   @FocusState private var chatTextViewFocus : Bool
   
   var disappearHandler : ((_ userName : String, _ userId : String, _ loungeId : String ) -> Void)?
   
   var body: some View {
      VStack {
         chattingView
         Spacer()
         chattingBar
            .padding(.bottom, 1.0)
      }
      .overlay {
         if viewModel.isDisplayPhotoViewer, let chat = viewModel.selectedChat {
            FWImageViewer(files: chat.files,
                          selectedImageIndex: $viewModel.photoViewerIndex) {
               chatTextViewFocus = false
               viewModel.send(action: .togglePhotoViewer)
            }
         }
      }
      .toolbar(.hidden, for: .tabBar)
      .toolbar(viewModel.isDisplayPhotoViewer ? .hidden : .visible, for: .navigationBar)
      .task {
         viewModel.send(action: .enterChannel)
      }
      .onDisappear {
         viewModel.send(action: .disconnect)
         if viewModel.isMoveToDM, let info = viewModel.anotherUserInfo {
            disappearHandler?(info.username, info.userId, viewModel.getLoungeId())
         }
      }
      .onChange(of: scenePhase) { _, updatedPhase in
         if updatedPhase == .inactive { viewModel.send(action: .disconnect) }
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
      .fullScreenCover(isPresented: $viewModel.isDisplayAnotherProfile) {
         VStack {
            HStack {
               Image(systemName: "xmark")
                  .font(.fwT2)
                  .onTapGesture {
                     viewModel.isDisplayAnotherProfile = false
                  }
               Spacer()
            }.padding(.horizontal, 20.0)
            
            if let info = viewModel.anotherUserInfo {
               ProfileView(viewModel: .init(
                  diContainer: diContainer,
                  userId: info.userId
               )) { userId in
                  viewModel.isDisplayAnotherProfile = false
                  viewModel.send(action: .leaveChannel)
               }
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
                  } profileTapHandler: { chat in
                     viewModel.send(action: .tapProfileImage(user: chat))
                  }
                  .id(viewModel.chats[index].id)
               }
               .padding(.horizontal, 15.0)
               .padding(.top, 10.0)
            }
         }
         .onChange(of: chatTextViewFocus) { _, newValue in
            if newValue {
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
