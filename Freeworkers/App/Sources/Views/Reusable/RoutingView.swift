// hankyeol-dev.

import SwiftUI

struct RoutingView : View {
   @Environment(\.dismiss) private var dismiss
   @EnvironmentObject var diContainer : DIContainer
   @State var destination : NavigationDestination
   
   var body: some View {
      switch destination {
      case let .lounge(loungeId):
         LoungeView(viewModel: .init(diContainer: diContainer, loungeId: loungeId))
            .navigationBarBackButtonHidden()
      case let .channel(channelTitle, channelId, loungeId):
         ChannelView(viewModel: .init(diContainer: diContainer, channelId: channelId, lougneId: loungeId))
            .navigationTitle(channelTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
               ToolbarItem(id: "backToLounge",
                           placement: .topBarLeading) {
                  Button {
                     dismiss()
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
      case .profile:
         ProfileView()
      }
   }
}
