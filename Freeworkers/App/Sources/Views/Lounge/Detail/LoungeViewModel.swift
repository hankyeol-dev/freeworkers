// hankyeol-dev.

import Foundation
import Combine

final class LoungeViewModel : ViewModelType {
   private let diContainer : DIContainer
   private let loungeId : String
   
   var store: Set<AnyCancellable> = .init()
   
   @Published var selectedTab : LoungeTabItem = .home
   @Published var sheetConfig : SheetConfig?
   @Published var channelToggleTapped : Bool = true
   @Published var directMessageToggleTapped : Bool = false
   @Published var loungeViewItem : LoungeViewItem = .init(
      loungeId: "", name: "", description: "", coverImage: "", channels: []
   )
   
   @Published var canCreateChannel : Bool = false
   @Published var createChannelName : String = ""
   @Published var createChannelDescription : String = ""
   
   enum Action {
      // ButtonTapped
      case channelToggleTapped
      case directMessageToggleTapped
      case createChannelButtonTapped
      case popToLounge
      
      // Data Fetch
      case fetchLounge
      
      // Valid
      case canCreateChannel(name : String)
      
      // Create
      case createChannel
      
      // Navigate
      case pushToChannel(channelTitle : String, channelId : String)
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
      case .popToLounge:
         diContainer.navigator.pop()
      case .fetchLounge:
         Task { await fetchLounge() }
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
      }
   }
}

extension LoungeViewModel {
   func getLoungeId() -> String {
      return loungeId
   }
   
   fileprivate func fetchLounge() async {
      diContainer.services.authService.setLatestEnteredChannel(loungeId: loungeId)
      await diContainer.services.workspaceService.getLounge(input: .init(loungeId: loungeId))
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
         } receiveValue: { viewItem in
            Task {
               await MainActor.run { [weak self] in
                  self?.loungeViewItem = viewItem
               }
            }
         }
         .store(in: &store)
   }
   
   fileprivate func validCreateChannelName(_ name : String) {
      canCreateChannel = diContainer.services.validateService.validateRoungeName(name)
   }
   
   fileprivate func createChannel() async {
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
            self?.loungeViewItem.channels.append(output)
            self?.sheetConfig = nil
            self?.send(action: .channelToggleTapped)
         }
         .store(in: &store)
   }
}
