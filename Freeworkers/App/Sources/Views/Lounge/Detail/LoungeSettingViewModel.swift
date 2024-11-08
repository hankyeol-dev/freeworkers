// hankyeol-dev.

import Foundation
import Combine

final class LoungeSettingViewModel : ViewModelType {
   private let diContainer : DIContainer
   private let loungeId : String
   var store: Set<AnyCancellable> = .init()
   
   enum Action {
      
   }
   
   init(diContainer : DIContainer, lougneId : String) {
      self.diContainer = diContainer
      self.loungeId = lougneId
   }
   
   func send(action: Action) {
      switch action {
      default:
         break;
      }
   }
}
