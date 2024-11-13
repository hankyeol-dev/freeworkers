// hankyeol-dev.

import Foundation
import Combine

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
   @Published var loungeListItem : [LoungeListViewItem] = []
   
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
      case popToLounge
      
      // Data Fetch
      case fetchLounge
      case fetchLounges
      case switchLounge(loungeId : String)
      
      // Valid
      case canCreateChannel(name : String)
      
      // Create
      case createChannel
      
      // Navigate
      case pushToChannel(channelTitle : String, channelId : String)
      case pushToProfile
   }
   
   enum SheetConfig : Int, Hashable, Identifiable {
      case createChannelSheet
      
      var id : Int { return self.rawValue }
   }
   
   init(diContainer: DIContainer, loungeId: String) {
      self.diContainer = diContainer
      self.loungeId = loungeId
   }
   
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
      case .popToLounge:
         diContainer.navigator.pop()
         
      case .fetchLounge:
         Task { await fetchLounge() }
      case .fetchLounges:
         Task { await fetchLounges() }
      case let .switchLounge(loungeId):
         Task { await switchLounge(loungeId)}
         
      case let .canCreateChannel(name):
         validCreateChannelName(name)
      case .createChannel:
         Task { await createChannel() }
      case let .pushToChannel(channelTitle, channelId):
         diContainer.navigator.push(
            to: .channel(channelTitle: channelTitle,
                         channelId: channelId,
                         loungeId: loungeId)
         )
      case .pushToProfile:
         diContainer.navigator.push(to: .profile)
      }
   }
}

extension LoungeViewModel {
   func getLoungeId() -> String {
      return loungeId
   }
   
   @MainActor
   private func fetchLounge() async {
      diContainer.services.authService.setLatestEnteredChannel(loungeId: loungeId)
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
      
      await diContainer.services.workspaceService.getLoungeMyChannel(loungeId: loungeId)
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { [weak self] viewItems in
            self?.loungeChannelViewItem = viewItems
         }
         .store(in: &store)
      
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
            self?.loungeChannelViewItem.append(output.toLoungeChannelViewItem)
            self?.sheetConfig = nil
            self?.send(action: .channelToggleTapped)
         }
         .store(in: &store)
   }
}
