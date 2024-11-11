// hankyeol-dev.

import Foundation

public protocol SocketEndpointProtocol {
   var baseURL : String { get }
   var connectionType : SocketConnectionType { get }
}
