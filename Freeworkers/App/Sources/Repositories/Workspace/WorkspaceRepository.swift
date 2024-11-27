// hankyeol-dev.

import Foundation
import FreeworkersNetworkKit

protocol WorkspaceRepositoryType : CoreRepositoryType {
   func getLounges() async -> Result<[LoungeCommonOutputType], RepositoryErrors>
   func getLounge(input : GetLoungeInputType) async -> Result<GetLoungeOutputType, RepositoryErrors>
   func getLoungeMyChannel(loungeId : String) async -> Result<[ChannelCommonOutputType], RepositoryErrors>
   func getLoungeMembers(input : GetLoungeInputType, exceptMe : Bool) async -> Result<[UserCommonOutputType], RepositoryErrors>

   func createRounge(input : CreateLoungeInput) async -> Result<Bool, RepositoryErrors>
   func inviteLounge(input : InviteLoungeInputType) async -> Result<Bool, RepositoryErrors>
   
   func editLounge(input : EditLoungeInputType) async -> Result<LoungeCommonOutputType, RepositoryErrors>
   func changeLoungeOwner(input : ChangeOwnerInputType) async -> Result<LoungeCommonOutputType, ServiceErrors>
   func exitLounge(loungeId : String) async -> Result<Bool, RepositoryErrors>
}

// MARK: GET
struct WorkspaceRepository : WorkspaceRepositoryType {
   func getLounges() async -> Result<[LoungeCommonOutputType], RepositoryErrors> {
      let result = await request(router: WorkspaceRouter.getLounges,
                                 of: [LoungeCommonOutputType].self)
      
      switch result {
      case let .success(output):
         return .success(output)
      case .failure:
         return .failure(.error(message: errorText.ERROR_LOUNGE_NOT_FOUND))
      }
   }
   
   func getLounge(input : GetLoungeInputType) async -> Result<GetLoungeOutputType, RepositoryErrors> {
      let result = await request(router: WorkspaceRouter.getLounge(inputType: input),
                                 of: GetLoungeOutputType.self)
      
      switch result {
      case let .success(output):
         return .success(output)
      case let .failure(errors):
         switch errors {
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
   
   func getLoungeMyChannel(loungeId: String) async -> Result<[ChannelCommonOutputType], RepositoryErrors> {
      let result = await request(router: WorkspaceRouter.getLoungeMyChannel(loungeId: loungeId),
                                 of: [ChannelCommonOutputType].self)
      switch result {
      case let .success(output):
         return .success(output)
      case let .failure(errors):
         switch errors {
         case .error(message: .E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
   
   func getLoungeMembers(input : GetLoungeInputType, exceptMe : Bool) async -> Result<[UserCommonOutputType], RepositoryErrors> {
      let result = await request(router: WorkspaceRouter.getLoungeMembers(InputType: input),
                                 of: [UserCommonOutputType].self)
      let meId = await UserDefaultsRepository.shared.getValue(.userId)
      
      switch result {
      case let .success(output):
         if exceptMe {
            return .success(output.filter({ $0.user_id != meId }))
         } else {
            return .success(output)
         }
      case .failure:
         return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
      }
   }
 
   func exitLounge(loungeId : String) async -> Result<Bool, RepositoryErrors> {
      let result = await request(router: WorkspaceRouter.exitLounge(loungeId: loungeId),
                                 of: [LoungeCommonOutputType].self)
      switch result {
      case .success:
         await UserDefaultsRepository.shared.setValue(.latestEnteredChannelId, value: "")
         return .success(true)
      case let .failure(errors):
         switch errors {
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         case .error(.E15):
            return .failure(.error(message: errorText.ERROR_CANT_EXIT_LOUNGE))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
}

// MARK: POST
extension WorkspaceRepository {
   func createRounge(input: CreateLoungeInput) async -> Result<Bool, RepositoryErrors> {
      let inputType: CreateLoungeInputType = .init(input: input)
      let result = await request(router: WorkspaceRouter.createLounge(inputType: inputType),
                                 of: LoungeCommonOutputType.self)
      
      switch result {
      case .success:
         return .success(true)
      case let .failure(error):
         switch error {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_BAD_REQUEST))
         case .error(.E12):
            return .failure(.error(message: errorText.ERROR_ROUNGENAME_OVERLAP))
         case .error(.E21):
            return .failure(.error(message: errorText.ERROR_ROUNGE_COIN_LACK))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
   
   func inviteLounge(input: InviteLoungeInputType) async -> Result<Bool, RepositoryErrors> {
      let result = await request(router: WorkspaceRouter.inviteLounge(inputType: input),
                                 of: UserCommonOutputType.self)
      switch result {
      case .success:
         return .success(true)
      case let .failure(errors):
         switch errors {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_BAD_REQUEST))
         case .error(.E12):
            return .failure(.error(message: errorText.ERROR_ALEADY_MEMBER))
         case .error(.E03), .error(.E13):
            return .failure(.error(message: errorText.ERROR_NO_MEMBER))
         case .error(.E14):
            return .failure(.error(message: errorText.ERROR_NO_AUTH))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
}

extension WorkspaceRepository {
   func editLounge(input: EditLoungeInputType) async -> Result<LoungeCommonOutputType, RepositoryErrors> {
      let result = await request(router: WorkspaceRouter.editLounge(inputType: input),
                           of: LoungeCommonOutputType.self)
      switch result {
      case let .success(output):
         return .success(output)
      case let .failure(errors):
         switch errors {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_BAD_REQUEST))
         case .error(.E12):
            return .failure(.error(message: errorText.ERROR_NO_CHANGE))
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_DATA_NOTFOUND))
         case .error(.E14):
            return .failure(.error(message: errorText.ERROR_NO_AUTH))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
   
   func changeLoungeOwner(input: ChangeOwnerInputType) async -> Result<LoungeCommonOutputType, ServiceErrors> {
      let result = await request(router: WorkspaceRouter.changeLoungeOwner(inputType: input),
                           of: LoungeCommonOutputType.self)
      switch result {
      case let .success(output):
         return .success(output)
      case let .failure(errors):
         switch errors {
         case .error(.E11):
            return .failure(.error(message: errorText.ERROR_BAD_REQUEST))
         case .error(.E13):
            return .failure(.error(message: errorText.ERROR_NO_MEMBER))
         case .error(.E14):
            return .failure(.error(message: errorText.ERROR_NO_AUTH))
         default:
            return .failure(.error(message: errorText.ERROR_UNKWON))
         }
      }
   }
}
