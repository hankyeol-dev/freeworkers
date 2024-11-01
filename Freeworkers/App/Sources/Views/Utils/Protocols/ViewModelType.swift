// hankyeol-dev.

import Foundation
import Combine

protocol ViewModelType : ObservableObject {
   
   associatedtype Action
   
   var store : Set<AnyCancellable> { get set }
   
   func send(action: Action)
}
