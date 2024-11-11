// hankyeol-dev.

import Foundation
import Combine

final class ChannelSettingViewModel : ViewModelType {
   private let diContainer : DIContainer
   private let loungeId : String
   private let channelId : String
   var store: Set<AnyCancellable> = .init()
   
   init(diContainer : DIContainer, loungeId : String, channelId : String) {
      self.diContainer = diContainer
      self.loungeId = loungeId
      self.channelId = channelId
   }
   
   @Published var settingViewItem : ChannelSettingViewItem?
   
   enum Action {
      case didLoad
   }
   
   func send(action: Action) {
      switch action {
      case .didLoad:
         Task { await fetchChannelInfo() }
      }
   }
}

extension ChannelSettingViewModel {
   private func fetchChannelInfo() async {
      let input: CommonChannelInputType = .init(channelId: channelId, loungeId: loungeId)
      await diContainer.services.channelService.getChannelInfo(input: input)
         .receive(on: DispatchQueue.main)
         .sink { errors in
            if case let .failure(error) = errors {
               print(error.errorMessage)
            }
          } receiveValue: { [weak self] viewItem in
            self?.settingViewItem = viewItem
         }
         .store(in: &store)
   }
}
