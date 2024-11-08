// hankyeol-dev.

import SwiftUI
import SwiftData
import FreeworkersDBKit

struct LoungeView : View {
   @EnvironmentObject var diContainer : DIContainer
   @StateObject var viewModel : LoungeViewModel
   
   var body: some View {
      TabView(selection: $viewModel.selectedTab) {
         LoungeMainView(viewModel: viewModel)
            .tabItem {
               viewModel.selectedTab == .home
               ? LoungeTabItem.home.toActiveImage
               : LoungeTabItem.home.toInActiveImage
            }
            .tag(LoungeTabItem.home)
         
         LoungeDMListView()
            .tabItem {
               viewModel.selectedTab == .directMessage
               ? LoungeTabItem.directMessage.toActiveImage
               : LoungeTabItem.directMessage.toInActiveImage
            }
            .tag(LoungeTabItem.directMessage)
         
         LoungeSearchView()
            .tabItem {
               viewModel.selectedTab == .search
               ? LoungeTabItem.search.toActiveImage
               : LoungeTabItem.search.toInActiveImage
            }
            .tag(LoungeTabItem.search)
         
         LoungeSettingView(viewModel: .init(diContainer: diContainer, lougneId: viewModel.getLoungeId()))
            .tabItem {
               viewModel.selectedTab == .setting
               ? LoungeTabItem.setting.toActiveImage
               : LoungeTabItem.setting.toInActiveImage
            }
            .tag(LoungeTabItem.setting)
      }
      .task {
         viewModel.send(action: .fetchLounge)
         // UITabBar.appearance().scrollEdgeAppearance = .init()
      }
      .sheet(item: $viewModel.sheetConfig) { config in
         switch config {
         case .createChannelSheet:
            LoungeChannelCreateView(viewModel: viewModel)
               .presentationDragIndicator(.visible)
               .presentationDetents([.medium])
         }
      }
   }
}

fileprivate struct LoungeMainView : View {
   @ObservedObject var viewModel : LoungeViewModel
   
   var body: some View {
      VStack {
         HStack {
            Text(viewModel.loungeViewItem.name.isEmpty ? "라운지" : viewModel.loungeViewItem.name)
               .foregroundStyle(.white)
               .frame(maxWidth: .infinity, alignment: .center)
         }
         .padding()
         .background(Color.primary)
         .frame(height: 40.0)
         
         ScrollView {
            LazyVStack(spacing: 15.0) {
               LoungeMainListHeader(
                  toggleCondition: $viewModel.channelToggleTapped,
                  HeaderTitle: workspaceTitle.LOUNGE_HOME_CHANNEL_TITLE) {
                     viewModel.send(action: .channelToggleTapped)
                  }
               
               withAnimation(.easeInOut) {
                  LoungeChannelListView(viewModel: viewModel)
               }
               
               // MARK: 채널 생성 버튼
               HStack {
                  Button {
                     viewModel.send(action: .createChannelButtonTapped)
                  } label: {
                     HStack(spacing : 5.0) {
                        Image(systemName: "plus")
                           .font(.fwRegular)
                           .foregroundStyle(.black)
                        Text(buttonTitle.CREATE_CHANNEL)
                           .font(.fwRegular)
                           .foregroundStyle(.black)
                        Spacer()
                     }
                  }
               }
               .padding(.leading, 25.0)
               
               Divider()
               
               // TODO: DMs 화면 구축 필요
            }
            .id(viewModel.getLoungeId() + "_homeTabScroll")
         }
         .padding(.top, 15.0)
         
         Spacer()
      }
      
   }
   
}

fileprivate struct LoungeMainListHeader : View {
   @Binding fileprivate var toggleCondition : Bool
   fileprivate let HeaderTitle : String
   fileprivate var action : () -> Void
   
   var body: some View {
      HStack {
         Text(HeaderTitle)
            .font(.fwT2)
         Spacer()
         Button {
            withAnimation(.easeInOut) {
               action()
            }
         } label: {
            withAnimation(.easeInOut) {
               Image(systemName: "chevron.up")
                  .resizable()
                  .frame(width: 10.0, height: 6.0)
                  .rotationEffect(
                     Angle(degrees: toggleCondition ? 180 : 0)
                  )
                  .foregroundStyle(.black)
            }
         }
      }
      .padding(.horizontal, 20.0)
   }
}

fileprivate struct LoungeChannelListView : View {
   @ObservedObject fileprivate var viewModel : LoungeViewModel
   
   var body: some View {
      ScrollView(.vertical) {
         if viewModel.channelToggleTapped {
            let channels = viewModel.loungeViewItem.channels
            if channels.isEmpty {
               Text(appTexts.CHANNEL_EMPTY_MESSAGE)
                  .font(.fwRegular)
                  .frame(maxWidth: .infinity, alignment: .center)
                  .padding(.horizontal, 25.0)
            } else {
               VStack {
                  ForEach(viewModel.loungeViewItem.channels, id: \.channel_id) { channel in
                     LazyVStack {
                        Text("# " + channel.name)
                           .font(.system(size: 15.0))
                           .frame(maxWidth: .infinity, alignment: .leading)
                           .padding(.horizontal, 25.0)
                           .padding(.bottom, 10.0)
                     }
                     .onTapGesture {
                        // TODO: 채널 채팅방 오픈 준비
                        viewModel.send(
                           action: .pushToChannel(channelTitle: channel.name,
                                                  channelId: channel.channel_id)
                        )
                     }
                  }
               }
            }
         }
      }
   }
}

fileprivate struct LoungeChannelCreateView : View {
   @ObservedObject fileprivate var viewModel : LoungeViewModel
   
   var body: some View {
      VStack(spacing: 20.0) {
         Spacer.height(30.0)
         
         VStack {
            Text(workspaceTitle.LOUNGE_CREATE_CHANNEL_NAME)
               .font(.fwT2)
               .foregroundStyle(.black)
               .frame(maxWidth: .infinity, alignment: .leading)
               .onChange(of: viewModel.createChannelName) { _, newValue in
                  viewModel.send(action: .canCreateChannel(name: newValue))
               }
            TextField("", text: $viewModel.createChannelName)
               .textFieldStyle(FWTextFieldStyle(keyboardType: .default))
         }
         
         VStack {
            Text(workspaceTitle.LOUNGE_CREATE_CHANNEL_DESCRIPTION)
               .font(.fwT2)
               .foregroundStyle(.black)
               .frame(maxWidth: .infinity, alignment: .leading)
            TextField("",text: $viewModel.createChannelDescription)
               .textFieldStyle(FWTextFieldStyle(keyboardType: .default))
         }
         .padding(.bottom, 5.0)
         
         
         FWRoundedButton(
            title: buttonTitle.CREATE_CHANNEL,
            height: 50.0,
            background: viewModel.canCreateChannel ? Color.primary : .gray,
            disabled: !viewModel.canCreateChannel
         ) {
            viewModel.send(action: .createChannel)
         }
         
         Spacer()
      }
      .padding(.horizontal, 20.0)
      .background(Color.bg)
   }
}
