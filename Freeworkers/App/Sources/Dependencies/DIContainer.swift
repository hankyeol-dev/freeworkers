// hankyeol-dev.

import Foundation

final class DIContainer: ObservableObject {
   var services: ServiceType
   
   init(services: ServiceType) {
      self.services = services
   }
}
