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
         ProfileView(viewModel: .init(diContainer: diContainer))
            .fwNavigationBackStyle(workspaceTitle.PROFILE_SETTING_TITLE) { diContainer.navigator.pop() }
      case let .fillCoin(coin):
         ProfileFillCoinView(coin: coin)
            .fwNavigationBackStyle("코인 충전") { diContainer.navigator.pop() }
      case let .patchNickname(nickname):
         ProfilePatchNicknameView(nickname: nickname, baseNickname: nickname)
            .fwNavigationBackStyle("닉네임 수정") { diContainer.navigator.pop() }
      case let .patchPhone(phone):
         ProfilePatchPhoneView(phone: phone, basePhone: phone)
            .fwNavigationBackStyle("전화번호 수정") { diContainer.navigator.pop() }
      }
   }
}
