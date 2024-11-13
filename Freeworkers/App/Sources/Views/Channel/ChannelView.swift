// hankyeol-dev.

import SwiftUI

struct ChannelView : View {
   @StateObject var viewModel : ChannelViewModel
   
   var body: some View {
      VStack {
         // TODO: Chatting View
         chattingView
         Spacer()
         chattingBar
            .padding(.horizontal, 20.0)
      }
      .padding(.vertical, 20.0)
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
   }
   
   @ViewBuilder
   var chattingView : some View {
      ScrollViewReader { proxy in
         ScrollView {
            ForEach(viewModel.chats, id: \.id) { chat in
               LazyVStack {
                  FWChat(chat: chat)
                     .id(chat.id)
               }
               .padding(.horizontal, 15.0)
            }
         }
         .onChange(of: viewModel.chats.last) { _, newValue in
            proxy.scrollTo(newValue?.id, anchor: .bottom)
         }
      }
   }
   
   @ViewBuilder
   var chattingBar : some View {
      HStack(alignment: .center, spacing: 10.0) {
         Button {} label: {
            Circle()
               .fill(Color.bg)
               .frame(width: 30.0, height: 30.0)
               .overlay {
                  Image(systemName: "plus")
                     .resizable()
                     .font(.fwT1)
                     .frame(width: 15.0, height: 15.0)
                     .foregroundStyle(.black)
               }
         }
         
         TextField("", text: $viewModel.chatText)
            .frame(height: 36.0)
            .font(.fwRegular)
            .foregroundStyle(.black)
            .tint(Color.black)
            .padding(.horizontal, 12.0)
            .background(Color.bg)
            .clipShape(RoundedRectangle(cornerRadius: 12.0))
         
         Button { viewModel.send(action: .sendChannelChat) } label: {
            Circle()
               .fill(Color.bg)
               .frame(width: 30.0, height: 30.0)
               .overlay {
                  Image(systemName: "arrow.up.circle.fill")
                     .resizable()
                     .font(.fwT1)
                     .frame(width: 15.0, height: 15.0)
                     .foregroundStyle(viewModel.chatText.isEmpty ? .gray : .black)
               }
         }
         .disabled(viewModel.chatText.isEmpty)
      }
      .frame(height: 40.0)
      .padding(.horizontal, 12.0)
   }
}
