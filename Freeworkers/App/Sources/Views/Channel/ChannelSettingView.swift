// hankyeol-dev.

import SwiftUI

struct ChannelSettingView : View {
   @StateObject var viewModel : ChannelSettingViewModel
   @State private var isMemberListOpen : Bool = true
   
   var body: some View {
      VStack {
         if let viewItem = viewModel.settingViewItem {
            ScrollView(.vertical) {
               Text("#" + viewItem.channelName)
                  .font(.fwT2)
                  .padding(.bottom, 10.0)
                  .padding(.horizontal, 20.0)
                  .frame(maxWidth: .infinity, alignment: .topLeading)
               Text(viewItem.channelDescription ?? "채널 설명이 없습니다.")
                  .font(.fwRegular)
                  .foregroundStyle(.gray)
                  .padding(.bottom, 20.0)
                  .padding(.horizontal, 20.0)
                  .frame(maxWidth: .infinity, alignment: .topLeading)
               
               FWFlipedHeader(
                  toggleCondition: $isMemberListOpen,
                  HeaderTitle: "멤버 (\(viewItem.members.count)명)"
               ) {}
               if isMemberListOpen {
                  FWMemberGrid(memberList: viewItem.members) { memberId in
                     print(memberId)
                  }
               }
            }
            .padding(.top, 20.0)
         } else {
            EmptyView()
         }
      }
      .task {
         viewModel.send(action: .didLoad)
      }
   }
}
