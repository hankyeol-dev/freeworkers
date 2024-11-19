// hankyeol-dev.

import Foundation
import Combine

final class EnvironmentContainer : ObservableObject {
   @Published var hideTab : Bool = false
   
   func toggleTab() { hideTab.toggle() }
}
