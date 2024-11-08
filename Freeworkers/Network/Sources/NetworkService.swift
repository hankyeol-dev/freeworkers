import Foundation

public struct NetworkService {
   private static let session: URLSession = .shared
   private static let decoder: JSONDecoder = .init()
   
   // NOTE: - Typed Throws는 XCode 16에서부터 지원한다.
   public static func request<T: Decodable>(
      endpoint: EndpointProtocol,
      of: T.Type
   ) async throws -> T {
      
      let request = try await endpoint.asURLRequest()
      let (data, res) = try await session.data(for: request)
      
      // MARK: response의 응답코드가 400인 경우, errorCode 값을 확인하여 에러 핸들링
      guard let res = res as? HTTPURLResponse,
            res.statusCode != 400 else {
         let errorCode = try decoder.decode(ErrorOutputType.self, from: data).errorCode
         print("errorCode: \(errorCode)")
         throw handleErrorOutput(errorCode)
      }
      
      do {
         return try decoder.decode(T.self, from: data)
      } catch {
         throw NetworkErrors.error(message: .E00)
      }
   }
   
   private static func handleErrorOutput(_ errorCode: String) -> NetworkErrors {
      if let type = NetworkErrorTypes(rawValue: errorCode) {
         return .error(message: type)
      } else {
         return .error(message: .E00)
      }
   }
}


public struct ErrorOutputType: Decodable {
   let errorCode: String
}
