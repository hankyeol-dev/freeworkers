// hankyeol-dev.

import SwiftUI

struct ChannelSettingView : View {
   @StateObject var viewModel : ChannelSettingViewModel
   @State private var isMemberListOpen : Bool = true
   
   var body: some View {
      VStack {
         if let viewItem = viewModel.settingViewItem {
            ScrollView(.vertical) {
               LazyVStack {
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
                  ) { isMemberListOpen.toggle() }
                  if isMemberListOpen {
                     FWMemberGrid(memberList: viewItem.members) { memberId in
                        print(memberId)
                     }
                  }
                  
                  FWSectionDivider(color : Color.bg, height: 10.0)
                  
                  
                  VStack(spacing: 15.0) {
                     Spacer()
                     if viewItem.isOwner {
                        FWRoundedButton(title: "채널에 멤버 초대", width: 320.0, height : 45.0) {
                           
                        }
                        
                        FWRoundedButton(title: "채널 편집", width: 320.0, height : 45.0) {
                           
                        }
                        
                        FWRoundedButton(title: "채널 관리자 변경", width: 320.0, height : 45.0) {
                           
                        }
                        
                        FWRoundedButton(
                           title: "채널 삭제",
                           width: 320.0,
                           height : 45.0,
                           foreground: .white,
                           background: .error
                        ) {
                           
                        }
                     } else {
                        FWRoundedButton(
                           title: "채널 나가기",
                           width: 320.0,
                           height : 45.0,
                           foreground: .white,
                           background: .error
                        ) {
                           
                        }
                     }
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
