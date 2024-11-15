// hankyeol-dev.

import Foundation
import SocketIO

public final actor SocketService {
   public static let shared: SocketService = .init()
   
   private init() {}
   
   private var socketManager : SocketManager?
   private var socket : SocketIOClient?
}

extension SocketService {
   /// channel -> channelId
   /// dm -> dm roomId
   public func connect(_ socketEndpoint : SocketEndpointProtocol, dataHandler : @escaping(Data) -> Void) {
      guard let url = URL(string: socketEndpoint.baseURL) else { return }
      socketManager = .init(socketURL: url, config: [.compress])
      socket = socketManager?.socket(forNamespace: socketEndpoint.connectionType.toNameSpace)
      
      receive(socketEndpoint, dataHandler: dataHandler)
      socket?.connect()
   }
   
   public func disconnect() {
      socket?.disconnect()
      socket?.removeAllHandlers()
      socket = nil
      socketManager = nil
   }
   
   private func receive(_ socketEndpoint : SocketEndpointProtocol,
                        dataHandler : @escaping(Data) -> Void) {
      socket?.on(socketEndpoint.connectionType.toEmitName) { res, _ in
         guard let data = res.first,
               let json = try? JSONSerialization.data(withJSONObject: data)
         else { return }
         dataHandler(json)
      }
   }
}
