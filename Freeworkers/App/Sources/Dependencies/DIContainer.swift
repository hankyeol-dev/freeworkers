// hankyeol-dev.

import Foundation

final class DIContainer: ObservableObject {
   var services : ServiceType
   var navigator : NavigatableType
   
   @Published var hideTab : Bool = false
   
   init(
      services: ServiceType,
      navigator : NavigatableType = NavigationProvider()
   ) {
      self.services = services
      self.navigator = navigator
      
      navigator.setObservablePublisher(objectWillChange)
   }
   
   func toggleTab() { hideTab.toggle() }
}
