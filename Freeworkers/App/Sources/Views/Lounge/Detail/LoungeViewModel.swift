// hankyeol-dev.

import Foundation
import Combine
import FreeworkersDBKit

final class LoungeViewModel : ViewModelType {
   private let diContainer : DIContainer
   private var loungeId : String
   
   var store: Set<AnyCancellable> = .init()
   
   @Published var selectedTab : LoungeTabItem = .home
   @Published var sheetConfig : SheetConfig?
   @Published var channelToggleTapped : Bool = true
   @Published var directMessageToggleTapped : Bool = false
   @Published var sideLoungeMenuTapped : Bool = false
   @Published var findChannelTapped : Bool = false
   
   @Published var meViewItem : MeViewItem?
   @Published var loungeViewItem : LoungeViewItem?
   @Published var loungeChannelViewItem : [LoungeChannelViewItem] = []
   @Published var loungeChannelChatCounts : [Int] = []
   @Published var loungeListItem : [LoungeListViewItem] = []
   @Published var loungeDMList : [DMListViewItemWithUnreads] = []
   
   @Published var canCreateChannel : Bool = false
   @Published var createChannelName : String = ""
   @Published var createChannelDescription : String = ""
   
   enum Action {
      // ButtonTapped
      case channelToggleTapped
      case directMessageToggleTapped
      case createChannelButtonTapped
      case findChannelButtonTapped
      case sideLoungeMenuTapped
      
      // Data Fetch
      case fetchLounge
      case fetchLounges
      case switchLounge(loungeId : String)
      
      // Valid
      case canCreateChannel(name : String)
      
      // Create
      case createChannel
      
      // Navigate
      case pushToProfile(userId : String)
      case pushToChannel(channelTitle : String, channelId : String)
      case pushToDM(dmItem : DMListViewItemWithUnreads)
   }
   
   enum SheetConfig : Int, Hashable, Identifiable {
      case createChannelSheet
      
      var id : Int { return self.rawValue }
   }
   
   init(diContainer: DIContainer, loungeId: String) {
      self.diContainer = diContainer
      self.loungeId = loungeId
   }
   
   deinit { print("loungeViewModel deinit") }
   
   func send(action: Action) {
      switch action {
      case .channelToggleTapped:
         channelToggleTapped.toggle()
      case .directMessageToggleTapped:
         directMessageToggleTapped.toggle()
      case .createChannelButtonTapped:
         sheetConfig = .createChannelSheet
      case .findChannelButtonTapped:
         findChannelTapped.toggle()
      case .sideLoungeMenuTapped:
         sideLoungeMenuTapped.toggle()
   
      case .fetchLounge:
         Task { await didLoad() }
      case .fetchLounges:
         Task { await fetchLounges() }
      case let .switchLounge(loungeId):
         Task { await switchLounge(loungeId)}
         
      case let .canCreateChannel(name):
         validCreateChannelName(name)
      case .createChannel:
         Task { await createChannel() }
      case let .pushToProfile(userId):
         diContainer.toggleTab()
         diContainer.navigator.push(to: .profile(userId: userId))
      case let .pushToChannel(channelTitle, channelId):
         diContainer.toggleTab()
         diContainer.navigator.push(
            to: .channel(channelTitle: channelTitle,
                         channelId: channelId,
                         loungeId: loungeId)
         )
      case let .pushToDM(dmItem):
         diContainer.toggleTab()
         diContainer.navigator.push(
            to: .dm(username: dmItem.dmViewItem.opponent.nickname,
                    userId: dmItem.dmViewItem.opponent.user_id,
                    loungeId: loungeId)
         )
      }
   }
}

// MARK: Fetch Lounge
extension LoungeViewModel {
   func getLoungeId() -> String {
      return loungeId
   }
   
   @MainActor
   private func didLoad() async {
      diContainer.services.authService.setLatestEnteredChannel(loungeId: loungeId)
      
      await fetchMe()
      await fetchLounge()
      await fetchMyChannels()
   }
   
   private func fetchMe() async {
      await diContainer.services.userService.getMe()
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { [weak self] meItem in
            self?.meViewItem = meItem
         }
         .store(in: &store)
   }
   
   private func fetchLounge() async {
      await diContainer.services.workspaceService.getLounge(input: .init(loungeId: loungeId))
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { [weak self] viewItem in
            self?.loungeViewItem = viewItem
         }
         .store(in: &store)
      
      await diContainer.services.dmService.getLoungeDmsWithUnreads(loungeId: loungeId) { items in
         DispatchQueue.main.async { [weak self] in
            self?.loungeDMList = items
         }
      }
   }
   
   private func fetchMyChannels() async {
      await diContainer.services.workspaceService.getLoungeMyChannel(loungeId: loungeId)
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { [weak self] viewItems in
            self?.loungeChannelViewItem = viewItems
            Task { [weak self] in
               await self?.fetchMyChannelsChatsCount(viewItems.map({ $0.channelId }))
            }
         }
         .store(in: &store)
   }
   
   @MainActor
   private func fetchMyChannelsChatsCount(_ channelIds : [String]) async {
      await withTaskGroup(of: Int.self) { [weak self] taskGroup in
         for id in channelIds {
            taskGroup.addTask { [weak self] in
               guard let self else { return 0 }
               return await fetchChannelLastCreatedAt(id)
            }
         }
         
         var counts : [Int] = []
         self?.loungeChannelChatCounts = []
         for await task in taskGroup {
            counts.append(task)
         }
         self?.loungeChannelChatCounts = counts
      }
   }
   
   private func fetchChannelLastCreatedAt(_ channelId : String) async -> Int {
      let chat = await diContainer.services.channelService.getchannelLastSaved(channelId: channelId)
      if let chat {
         return await diContainer.services.channelService.getChannelUnreads(
            input: .init(loungeId: loungeId, roomId: chat.roomId, createdAt: chat.createdAt)
         )
      } else {
         return 0
      }
   }
}

// MARK: Side Menu
extension LoungeViewModel {
   @MainActor
   private func fetchLounges() async {
      await diContainer.services.workspaceService.getLounges()
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { [weak self] list in
            self?.loungeListItem = list
         }
         .store(in: &store)
   }
   
   @MainActor
   private func switchLounge(_ loungeId : String) async {
      diContainer.services.authService.setLatestEnteredChannel(loungeId: loungeId)
      self.loungeId = loungeId
      send(action: .sideLoungeMenuTapped)
      send(action: .fetchLounge)
   }
}

// MARK: Create Channel
extension LoungeViewModel {
   private func validCreateChannelName(_ name : String) {
      canCreateChannel = diContainer.services.validateService.validateRoungeName(name)
   }
   
   private func createChannel() async {
      let input: CreateChannelInputType = .init(loungeId: loungeId,
                                                content: .init(
                                                   name: createChannelName,
                                                   description: createChannelDescription),
                                                image: nil)
      await diContainer.services.channelService.createChannel(input: input)
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { [weak self] output in
            self?.loungeChannelViewItem.insert(output.toLoungeChannelViewItem, at: 0)
            self?.sheetConfig = nil
            // self?.send(action: .channelToggleTapped)
         }
         .store(in: &store)
   }
}
