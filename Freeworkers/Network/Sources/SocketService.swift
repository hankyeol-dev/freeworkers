// hankyeol-dev.

import Foundation

public final actor SocketService {
   public static let shared: SocketService = .init()
   
   private init() {}
   
   private let session: URLSession = .shared
   private var webSocket: URLSessionWebSocketTask?
   private var timer: Timer?
   
}

extension SocketService {
   public func connect(endpoint : SockeEndpointProtocol) async {
      guard let request = try? endpoint.asSocketRequest() else {
         print("request erorr")
         return
      }
      webSocket = session.webSocketTask(with: request)
      webSocket?.resume()
      await startPing(endpoint.pingInterval)
   }
   
   public func disConnect() {
      print("disconnect!")
      stopPing()
   }

   public func receive<OutputType : Decodable>() async -> OutputType? {
      guard let webSocket else { return nil }
      guard let receive = try? await webSocket.receive() else { return nil }
      
      switch receive {
      case let .data(output):
         return handleReceive(output)
      default:
         return nil
      }
   }
   
   private func handleReceive<OutputType : Decodable>(_ data: Data) -> OutputType? {
      guard let data = try? JSONDecoder().decode(OutputType.self, from: data) else { return nil }
      return data
   }
}

// MARK: - ping & pong
extension SocketService {
   private func startPing(_ pingInterval: TimeInterval) async {
      timer?.invalidate()
      timer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true, block: { _ in
         Task { [weak self] in
            await self?.sendPing(pingInterval)
         }
      })
   }
   
   private func sendPing(_ pingInterval: TimeInterval) async {
      webSocket?.sendPing { pingError in
         // pong handling
         if let pingError { print(pingError) }
         Task { [weak self] in
            print("ping!")
            await self?.startPing(pingInterval)
         }
      }
   }
   
   private func stopPing() {
      webSocket?.cancel()
      webSocket = nil
      timer = nil
   }
}
