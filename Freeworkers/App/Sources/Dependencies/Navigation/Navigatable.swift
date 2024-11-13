// hankyeol-dev.

import Foundation
import Combine

enum NavigationDestination : Hashable {
   // MARK: 여기에 네비게이션 할 뷰 케이스 할당
   case lounge(loungeId : String)
   case channel(channelTitle: String, channelId : String, loungeId : String)
   case channelSetting(channelId : String, loungeId : String)
   
   case profile
   case fillCoin(coin : Int)
   case patchNickname(nickname : String)
   case patchPhone(phone : String)
}

// Router, Coordinator Pattern
protocol NavigatableType {
   var observablePublihser : ObservableObjectPublisher? { get set }
   var destination : [NavigationDestination] { get set }
   
   func push(to view : NavigationDestination)
   func pop()
   func popToRoot()
   
   func setObservablePublisher(_ publisher : ObservableObjectPublisher)
}
