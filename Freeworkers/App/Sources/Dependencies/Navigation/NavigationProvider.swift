// hankyeol-dev.

import Foundation
import Combine

final class NavigationProvider : NavigatableType {
   var observablePublihser: ObservableObjectPublisher?
   
   var destination: [NavigationDestination] = [] {
      didSet {
         observablePublihser?.send()
      }
   }
   
   func push(to view: NavigationDestination) {
      destination.append(view)
   }
   
   func pop() {
      destination.removeLast()
   }
   
   func popToRoot() {
      destination = []
   }
   
   func setObservablePublisher(_ publisher : ObservableObjectPublisher) {
      observablePublihser = publisher
   }
}
