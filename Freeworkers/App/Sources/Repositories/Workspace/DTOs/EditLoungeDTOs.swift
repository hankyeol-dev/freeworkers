// hankyeol-dev.

import Foundation

struct EditLoungeInputType {
   var loungeId : String
   var content : EditLoungeContentInput
   var file : EditLoungeFileInput
   
   var isImageEmpty : Bool { return file.image == nil }
}

struct EditLoungeContentInput : Encodable {
   var name : String
   var description : String?
}

struct EditLoungeFileInput {
   var boundary : String = UUID().uuidString
   var image : Data?
}
