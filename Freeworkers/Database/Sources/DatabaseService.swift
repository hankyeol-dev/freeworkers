import Foundation
import SwiftData

public final class DatabaseService {
   private let modelContainer : ModelContainer
   private let modelContext : ModelContext
   
   @MainActor public static let shared : DatabaseService = .init()
   
   @MainActor private init() {
      self.modelContainer = try! ModelContainer(
         for: Chat.self,
         configurations: .init(isStoredInMemoryOnly: false))
      self.modelContext = modelContainer.mainContext
   }
   
   @MainActor public func getContainer() -> ModelContainer {
      return modelContainer
   }
   
   @MainActor public func fetchRecords() -> [Chat]? {
      return try? modelContext.fetch(FetchDescriptor<Chat>())
   }
   
   @MainActor public func fetchRecords(_ predicateModel : Predicate<Chat>) -> [Chat]? {
      let descriptor = FetchDescriptor<Chat>(predicate: predicateModel)
      return try? modelContext.fetch(descriptor)
   }
   
   @MainActor public func addRecord(_ input : Chat) {
      modelContext.insert(input)
   }
}
