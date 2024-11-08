// hankyeol-dev.

import SwiftUI

struct ChannelView : View {
   @StateObject var viewModel : ChannelViewModel
   
   var body: some View {
      VStack {
         // TODO: Chatting View
         ScrollView {
            ForEach(viewModel.chats, id: \.id) { chat in
               VStack {
                  Text(chat.content)
                     .font(.fwRegular)
                     .frame(maxWidth: .infinity)
               }
            }
         }
         
         Spacer()
         HStack(alignment: .center, spacing: 10.0) {
            Button {} label: {
               Circle()
                  .fill(Color.bg)
                  .frame(width: 30.0, height: 30.0)
                  .overlay {
                     Image(systemName: "plus")
                        .resizable()
                        .frame(width: 13.0, height: 13.0)
                        .foregroundStyle(Color.primary)
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
                     Image(.send)
                        .resizable()
                        .frame(width: 13.0, height: 13.0)
                        .foregroundStyle(viewModel.chatText.isEmpty ? .gray : Color.primary)
                  }
            }
            .disabled(viewModel.chatText.isEmpty)
         }
         .frame(height: 40.0)
         .padding(.horizontal, 12.0)
      }
      .padding(.horizontal, 20.0)
      .padding(.bottom, 20.0)
      .task {
         viewModel.send(action: .enterChannel)
      }
      .onDisappear {
         viewModel.send(action: .moveOutFromChannel)
      }
   }
}
