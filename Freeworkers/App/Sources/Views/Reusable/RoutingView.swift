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
            .fwNavigationBackStyle(channelTitle) { diContainer.navigator.pop() }
      case let .channelSetting(channelId, loungeId):
         ChannelSettingView(viewModel: .init(diContainer: diContainer,
                                             loungeId: loungeId,
                                             channelId: channelId))
         .fwNavigationBackStyle(workspaceTitle.CHANNEL_SETTING_TITLE) { diContainer.navigator.pop() }
      case .profile:
         ProfileView()
            .fwNavigationBackStyle(workspaceTitle.PROFILE_SETTING_TITLE) { diContainer.navigator.pop() }
      }
   }
}
