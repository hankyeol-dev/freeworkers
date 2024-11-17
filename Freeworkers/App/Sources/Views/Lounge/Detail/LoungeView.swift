// hankyeol-dev.

import SwiftUI
import SwiftData
import FreeworkersDBKit

struct LoungeView : View {
   @EnvironmentObject var diContainer : DIContainer
   @StateObject var viewModel : LoungeViewModel
   
   var body: some View {
      ZStack {
         tabView
         LoungeSideMenu(isDisplay: $viewModel.sideLoungeMenuTapped, viewModel: viewModel)
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
      VStack {
         ZStack {
            switch viewModel.selectedTab {
            case .home:
               LoungeMainView(viewModel: viewModel)
            case .directMessage:
               LoungeDMListView(
                  viewModel: .init(diContainer: diContainer, loungeId: viewModel.getLoungeId())
               )
            case .search:
               LoungeSearchView()
            case .setting:
               if let loungeViewItem = viewModel.loungeViewItem {
                  LoungeSettingView(
                     viewModel: .init(
                        diContainer: diContainer,
                        loungeItem: loungeViewItem)
                  )
               }
            }
         }
         Spacer()
         if !diContainer.hideTab {
            loungeTabBar
         }
      }
   }
   
   @ViewBuilder
   var loungeTabBar : some View {
      HStack(alignment: .center, spacing: 10.0) {
         Spacer()
         ForEach(LoungeTabItem.allCases, id:\.self) { item in
            loungeTabItem(item)
            Spacer()
         }
      }
      .padding()
   }
   
   @ViewBuilder
   func loungeTabItem(_ tabItem : LoungeTabItem) -> some View {
      Button { viewModel.selectedTab = tabItem } label: {
         if viewModel.selectedTab == tabItem  {
            tabItem.toActiveImage
               .resizable()
               .frame(width: 24.0, height: 24.0)
         } else {
            tabItem.toInActiveImage
               .resizable()
               .frame(width: 24.0, height: 24.0)
         }
      }
   }
}

fileprivate struct LoungeMainView : View {
   @EnvironmentObject var diContainer : DIContainer
   @ObservedObject var viewModel : LoungeViewModel
   
   var body: some View {
      NavigationStack(path: $diContainer.navigator.destination) {
         VStack {
            header
            
            ScrollView {
               LazyVStack(spacing: 15.0) {
                  FWFlipedHeader(
                     toggleCondition: $viewModel.channelToggleTapped,
                     HeaderTitle: workspaceTitle.LOUNGE_HOME_CHANNEL_TITLE) {
                        viewModel.send(action: .channelToggleTapped)
                     }
                  
                  LoungeChannelListView(viewModel: viewModel)
                  
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
                  
                  // MAKR: 채널 조회 버튼
                  HStack {
                     Button {
                        viewModel.send(action: .findChannelButtonTapped)
                     } label: {
                        HStack(spacing : 5.0) {
                           Image(systemName: "plus")
                              .font(.fwRegular)
                              .foregroundStyle(.black)
                           Text(buttonTitle.FIND_CHANNEL)
                              .font(.fwRegular)
                              .foregroundStyle(.black)
                           Spacer()
                        }
                     }
                  }
                  .padding(.leading, 25.0)
                  
                  Divider()
                  
                  FWFlipedHeader(
                     toggleCondition: $viewModel.directMessageToggleTapped,
                     HeaderTitle: workspaceTitle.LOUNGE_HOME_DM_TITLE) {
                        viewModel.send(action: .directMessageToggleTapped)
                     }
                  
                  LoungeMainDMListView(viewModel: viewModel)
               }
               .id(viewModel.getLoungeId() + "_homeTabScroll")
            }
            .padding(.top, 15.0)
            
            Spacer()
         }
         .fullScreenCover(isPresented: $viewModel.findChannelTapped) {
            findChannelView
         }
         .navigationDestination(for: NavigationDestination.self) { destination in
            RoutingView(destination: destination)
         }
         .onAppear {
            if diContainer.hideTab { diContainer.toggleTab() }
            viewModel.send(action: .fetchLounge)
         }
      }
   }
   
   private var header : some View {
      HStack(spacing: 20.0) {
         Image(.sideMenu)
            .resizable()
            .frame(width: 20.0, height: 20.0)
            .onTapGesture {
               viewModel.send(action: .sideLoungeMenuTapped)
               viewModel.send(action: .fetchLounges)
            }
         if let loungeViewItem = viewModel.loungeViewItem {
            Text(loungeViewItem.name)
               .foregroundStyle(.black)
         }
         
         Spacer()
         if let meViewItem = viewModel.meViewItem,
            let profileImage = meViewItem.profileImage {
            FWImage(imagePath: profileImage)
               .frame(width: 25.0, height: 25.0)
               .clipShape(Circle())
               .onTapGesture {
                  viewModel.send(action: .pushToProfile(userId: meViewItem.userId))
               }
         }
      }
      .padding()
      .background(Color.bg)
      .frame(height: 40.0)
   }
   
   private var findChannelView : some View {
      VStack {
         HStack {
            Image(systemName: "xmark")
               .resizable()
               .frame(width: 15.0, height: 15.0)
               .foregroundStyle(.black)
               .onTapGesture {
                  viewModel.send(action: .findChannelButtonTapped)
               }
            Spacer()
         }
         .padding(25.0)
         
         if let viewItem = viewModel.loungeViewItem {
            ForEach(viewItem.channels, id: \.channelId) { channel in
               LazyVStack {
                  Text("# \(channel.channelName)")
                     .font(.system(size: 16.0))
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .padding(.horizontal, 25.0)
                     .padding(.vertical, 5.0)
                     .onTapGesture {
                        viewModel.send(action: .findChannelButtonTapped)
                        viewModel.send(
                           action: .pushToChannel(channelTitle: channel.channelName,
                                                  channelId: channel.channelId)
                        )
                     }
               }
            }
         }
         
         Spacer()
      }
      .background(Color.bg)
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
                  
                  ScrollView(.vertical) {
                     ForEach(viewModel.loungeListItem, id: \.loungeId) { lounge in
                        let selectedLounge = viewModel.getLoungeId() == lounge.loungeId
                        LazyVStack {
                           HStack(spacing: 12.0) {
                              Spacer.width(10.0)
                              FWImage(imagePath: lounge.coverImage)
                                 .frame(width: 44.0, height: 44.0)
                                 .clipShape(RoundedRectangle(cornerRadius: 8.0))
                              
                              VStack(alignment: .leading, spacing: 5.0) {
                                 Text(lounge.loungeName)
                                    .font(.fwT2)
                                    .foregroundStyle(selectedLounge ? .white : .black)
                                    .lineLimit(1)
                                 Text(lounge.createdAt.toISO860().toChatDate() + "오픈")
                                    .font(.fwRegular)
                                    .foregroundStyle(selectedLounge ? .white : .gray.opacity(1.5))
                              }
                              
                              Spacer()
                           }
                           .frame(height: 60.0)
                           .background(selectedLounge ? Color.primary : Color.clear)
                           .clipShape(UnevenRoundedRectangle(
                              cornerRadii: .init(topLeading: 5.0,
                                                 bottomLeading: 5.0)))
                           .padding(.vertical, 8.0)
                           .padding(.leading, 15.0)
                           .onTapGesture {
                              if viewModel.getLoungeId() != lounge.loungeId {
                                 viewModel.send(action: .switchLounge(loungeId: lounge.loungeId))
                              }
                           }
                        }
                     }
                  }
                  
                  Divider()
                  
                  HStack {
                     FWRoundedButton(title: "새로운 라운지 만들기", width: 240.0, height: 40.0) {}
                  }.frame(maxWidth: .infinity, alignment: .center)
                  
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
                  ForEach(viewModel.loungeChannelViewItem.indices, id: \.self) { index in
                     let channel = viewModel.loungeChannelViewItem
                     let channelChatCountList = viewModel.loungeChannelChatCounts
                     LazyVStack {
                        HStack {
                           if channelChatCountList.count == channel.count {
                              Text("# \(channel[index].channelName)")
                                 .font(.system(size: 15.0,
                                               weight: channelChatCountList[index] != 0
                                               ? .semibold 
                                               : .regular)
                                 )
                              Spacer()
                              if channelChatCountList[index] != 0 {
                                 RoundedRectangle(cornerRadius: 10.0)
                                    .fill(Color.primary)
                                    .frame(width: 40.0, height: 20.0)
                                    .overlay {
                                       Text(String(channelChatCountList[index]))
                                          .font(.fwCaption)
                                          .foregroundStyle(.white)
                                    }
                              }
                           }
                        }
                        .padding(.horizontal, 25.0)
                        .padding(.vertical, 5.0)
                     }
                     .onTapGesture {
                        viewModel.send(
                           action: .pushToChannel(channelTitle: channel[index].channelName,
                                                  channelId: channel[index].channelId)
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

fileprivate struct LoungeMainDMListView : View {
   @ObservedObject fileprivate var viewModel : LoungeViewModel
   
   var body: some View {
      ScrollView(.vertical) {
         if viewModel.directMessageToggleTapped {
            let dms = viewModel.loungeDMList
            if dms.isEmpty {
               EmptyView()
            } else {
               ForEach(dms.indices, id:\.self) { index in
                  LazyVStack {
                     let opponent = dms[index].dmViewItem.opponent
                     let unreads = dms[index].unreads
                     HStack {
                        FWImage(imagePath: opponent.profileImage ?? "/")
                           .frame(width: 20.0, height: 20.0)
                        Spacer.width(15.0)
                        Text(opponent.nickname)
                           .font(.fwRegular)
                        
                        Spacer()
                        
                        if unreads != 0 {
                           RoundedRectangle(cornerRadius: 10.0)
                              .fill(Color.primary)
                              .frame(width: 35.0, height: 20.0)
                              .overlay {
                                 Text(unreads > 99 ? "+ 99" : String(unreads))
                                    .font(.fwCaption)
                                    .foregroundStyle(.white)
                              }
                        }
                     }
                     .padding(.horizontal, 25.0)
                     .padding(.vertical, 5.0)
                  }
                  .onTapGesture {
                     viewModel.send(action: .pushToDM(dmItem: dms[index]))
                  }
               }
            }
         }
      }
   }
}
