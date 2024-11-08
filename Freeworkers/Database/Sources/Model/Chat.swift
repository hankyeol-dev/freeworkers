// hankyeol-dev.

import Foundation
import SwiftData

@Model
public final class Chat {
   @Attribute(.unique) public var id : String
   public var content : String
   public var files : [String]
   public var createdAt : String
   
   // Lounge and Room
   public var loungeId : String
   public var roomId : String
   
   // USER
   public var userId : String
   public var username : String
   public var userProfileImage : String?
   public var me : Bool
   
   public init(
      id: String,
      content: String,
      files: [String],
      createdAt: String,
      loungeId: String,
      roomId: String,
      userId: String,
      username: String,
      userProfileImage: String? = nil,
      me: Bool
   ) {
      self.id = id
      self.content = content
      self.files = files
      self.createdAt = createdAt
      self.loungeId = loungeId
      self.roomId = roomId
      self.userId = userId
      self.username = username
      self.userProfileImage = userProfileImage
      self.me = me
   }
}
