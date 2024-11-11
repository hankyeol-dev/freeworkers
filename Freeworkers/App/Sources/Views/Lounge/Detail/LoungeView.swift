// hankyeol-dev.

import SwiftUI
import SwiftData
import FreeworkersDBKit

struct LoungeView : View {
   @EnvironmentObject var diContainer : DIContainer
   @StateObject var viewModel : LoungeViewModel
   @State private var isChanged : Bool = false
   
   var body: some View {
      ZStack {
         tabView
         LoungeSideMenu(isDisplay: $viewModel.sideLoungeMenuTapped, viewModel: viewModel)
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
   
   @ViewBuilder
   var tabView : some View {
      TabView(selection: $viewModel.selectedTab) {
         LoungeMainView(viewModel: viewModel)
            .tabItem {
               viewModel.selectedTab == .home
               ? LoungeTabItem.home.toActiveImage
               : LoungeTabItem.home.toInActiveImage
            }
            .tag(LoungeTabItem.home)
            .id(LoungeTabItem.home)
         
         LoungeDMListView()
            .tabItem {
               viewModel.selectedTab == .directMessage
               ? LoungeTabItem.directMessage.toActiveImage
               : LoungeTabItem.directMessage.toInActiveImage
            }
            .tag(LoungeTabItem.directMessage)
            .id(LoungeTabItem.directMessage)
         
         LoungeSearchView()
            .tabItem {
               viewModel.selectedTab == .search
               ? LoungeTabItem.search.toActiveImage
               : LoungeTabItem.search.toInActiveImage
            }
            .tag(LoungeTabItem.search)
            .id(LoungeTabItem.search)
         
         LoungeSettingView(viewModel: .init(diContainer: diContainer,
                                            loungeItem: viewModel.loungeViewItem)
         )
         .tabItem {
            viewModel.selectedTab == .setting
            ? LoungeTabItem.setting.toActiveImage
            : LoungeTabItem.setting.toInActiveImage
         }
         .tag(LoungeTabItem.setting)
         .id(LoungeTabItem.setting)
      }
   }
   
}

fileprivate struct LoungeMainView : View {
   @EnvironmentObject var diContainer : DIContainer
   @ObservedObject var viewModel : LoungeViewModel
   
   var body: some View {
      NavigationStack(path: $diContainer.navigator.destination) {
         VStack {
            HStack(spacing: 20.0) {
               Image(.sideMenu)
                  .resizable()
                  .frame(width: 20.0, height: 20.0)
                  .onTapGesture {
                     viewModel.send(action: .sideLoungeMenuTapped)
                     viewModel.send(action: .fetchLounges)
                  }
               Text(viewModel.loungeViewItem.name.isEmpty ? "라운지" : viewModel.loungeViewItem.name)
                  .foregroundStyle(.black)
               Spacer()
            }
            .padding()
            .background(Color.bg)
            .frame(height: 40.0)
            
            ScrollView {
               LazyVStack(spacing: 15.0) {
                  FWFlipedHeader(
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
         .navigationDestination(for: NavigationDestination.self) { destination in
            RoutingView(destination: destination)
         }
      }
   }
}

fileprivate struct LoungeSideMenu : View {
   @Binding fileprivate var isDisplay : Bool
   @ObservedObject fileprivate var viewModel : LoungeViewModel
   
   var body: some View {
      ZStack {
         if isDisplay {
            Rectangle()
               .opacity(0.3)
               .ignoresSafeArea()
               .onTapGesture {
                  viewModel.send(action: .sideLoungeMenuTapped)
               }
            HStack {
               VStack(alignment: .leading) {
                  Text(workspaceTitle.JOINED_LOUNGE_LIST)
                     .font(.fwT1)
                     .padding(.horizontal, 20.0)
                     .padding(.top, 15.0)
                     .padding(.bottom, 10.0)
                  
                  Divider()
                  
                  Spacer.height(10.0)
                  
                  // TODO: LoungeList
                  ScrollView(.vertical) {
                     ForEach(viewModel.loungeListItem, id: \.loungeId) { lounge in
                        LazyVStack {
                           HStack(spacing: 10.0) {
                              Spacer()
                              FWImage(imagePath: lounge.coverImage)
                                 .frame(width: 20.0, height: 20.0)
                                 .clipShape(RoundedRectangle(cornerRadius: 8.0))
                              Text(lounge.loungeName)
                                 .font(.system(size: 16.0, weight: .regular))
                                 .padding(15.0)
                           }
                           .background(viewModel.getLoungeId() == lounge.loungeId
                                       ? Color.primary.opacity(0.5) : Color.clear)
                           .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 8.0,
                                                                                bottomLeading: 8.0)))
                           .padding(.vertical, 5.0)
                           .padding(.leading, 15.0)
                           .onTapGesture {
                              if viewModel.getLoungeId() != lounge.loungeId {
                                 viewModel.send(action: .switchLounge(loungeId: lounge.loungeId))
                              }
                           }
                        }
                     }
                  }
                  // TODO: 유저가 나가면 disconnect
                  Spacer()
               }
               .frame(width: 310.0, alignment: .topLeading)
               .background(.white)
               
               Spacer()
            }
            .transition(.move(edge: .leading))
         }
      }
      .animation(.easeOut, value: isDisplay)
   }
}

fileprivate struct LoungeChannelListView : View {
   @ObservedObject fileprivate var viewModel : LoungeViewModel
   
   var body: some View {
      ScrollView(.vertical) {
         if viewModel.channelToggleTapped {
            let channels = viewModel.loungeChannelViewItem
            if channels.isEmpty {
               Text(appTexts.CHANNEL_EMPTY_MESSAGE)
                  .font(.fwRegular)
                  .frame(maxWidth: .infinity, alignment: .center)
                  .padding(.horizontal, 25.0)
            } else {
               VStack {
                  ForEach(viewModel.loungeChannelViewItem, id: \.channelId) { channel in
                     LazyVStack {
                        Text("# \(channel.channelName)")
                           .font(.system(size: 16.0))
                           .frame(maxWidth: .infinity, alignment: .leading)
                           .padding(.horizontal, 25.0)
                           .padding(.vertical, 5.0)
                     }
                     .onTapGesture {
                        // TODO: 채널 채팅방 오픈 준비
                        viewModel.send(
                           action: .pushToChannel(channelTitle: channel.channelName,
                                                  channelId: channel.channelId)
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
