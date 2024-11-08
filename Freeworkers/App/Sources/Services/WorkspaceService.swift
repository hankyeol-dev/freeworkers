// hankyeol-dev.

import Foundation
import Combine

protocol WorkspaceServiceType {
   func getLounges() async -> AnyPublisher<[LoungeListViewItem], ServiceErrors>
   func getLounge(input : GetLoungeInputType) async -> AnyPublisher<LoungeViewItem, ServiceErrors>
   func getLoungeMembers(input : GetLoungeInputType) async -> AnyPublisher<[UserCommonOutputType], ServiceErrors>
   
   func createWorkspace(input : CreateLoungeInput) async -> AnyPublisher<Bool, ServiceErrors>
   func inviteLounge(input : InviteLoungeInputType) async -> AnyPublisher<Bool, ServiceErrors>
}

struct WorkspaceService : WorkspaceServiceType {
   private let workspaceRepository: WorkspaceRepositoryType
   
   init(workspaceRepository: WorkspaceRepositoryType) {
      self.workspaceRepository = workspaceRepository
   }
}

// MARK: GET
extension WorkspaceService {
   func getLounges() async -> AnyPublisher<[LoungeListViewItem], ServiceErrors> {
      let result = await workspaceRepository.getLounges()
      
      return Future { promise in
         switch result {
         case let .success(output):
            promise(.success(output.map { $0.toViewItem }))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func getLounge(input : GetLoungeInputType) async -> AnyPublisher<LoungeViewItem, ServiceErrors> {
      let result = await workspaceRepository.getLounge(input: input)
      return Future { promise in
         switch result {
         case let .success(output):
            promise(.success(output.toViewItem))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func getLoungeMembers(input: GetLoungeInputType) async -> AnyPublisher<[UserCommonOutputType], ServiceErrors> {
      let result = await workspaceRepository.getLoungeMembers(input: input)
      return Future { promise in
         switch result {
         case let .success(output):
            promise(.success(output))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
}

// MARK: POST, CREATE
extension WorkspaceService {
   func createWorkspace(input: CreateLoungeInput) async -> AnyPublisher<Bool, ServiceErrors> {
      let createState = await workspaceRepository.createRounge(input: input)
      return Future { promise in
         switch createState {
         case .success:
            promise(.success(true))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
   
   func inviteLounge(input: InviteLoungeInputType) async -> AnyPublisher<Bool, ServiceErrors> {
      let result = await workspaceRepository.inviteLounge(input: input)
      return Future { promise in
         switch result {
         case .success:
            promise(.success(true))
         case let .failure(error):
            promise(.failure(.error(message: error.errorMessage)))
         }
      }.eraseToAnyPublisher()
   }
}