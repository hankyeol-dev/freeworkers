// hankyeol-dev.

import Foundation

struct CreateLoungeInputType {
   let boundary : String = UUID().uuidString
   let input : CreateLoungeInput
}

struct CreateLoungeInput : Encodable {
   let name : String
   let image : [Data]
   let description : String?
   
   var toDict : [String : String] {
      return description != nil ? ["name" : name, "description" : description!] : ["name" : name]
   }
}

struct LoungeCommonOutputType : Decodable {
   let workspace_id : String
   let name : String
   let description : String?
   let coverImage : String
   let owner_id : String
   let createdAt : String
   
   var toViewItem : LoungeListViewItem {
      return .init(loungeId: workspace_id, 
                   loungeName: name,
                   description: description,
                   coverImage: coverImage,
                   ownerId: owner_id)
   }
}
