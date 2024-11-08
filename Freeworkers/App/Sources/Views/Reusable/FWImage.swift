// hankyeol-dev.

import SwiftUI
import Kingfisher

struct FWImage<PlaceholderView : View> : View {
   private var imageURL : String
   private var width : CGFloat
   private var height : CGFloat
   
   private var placeholderView : () -> PlaceholderView
   
   @State private var imageModifier : AnyModifier = .init { request in
      request
   }
   
   init(imageURL : String, 
        width : CGFloat,
        height : CGFloat,
        placeholderView : @escaping () -> PlaceholderView) {
      self.imageURL = imageURL
      self.width = width
      self.height = height
      self.placeholderView = placeholderView
   }
   
   
   var body: some View {
      KFImage(getImageURL)
         .requestModifier(imageModifier)
         .fade(duration: 0.25)
         .onFailure({ error in
//            print(error)
         })
         .placeholder {
            placeholderView()
         }
         .resizable()
         .frame(width: width, height: height)
         .scaledToFill()
         .task {
            await getImageModifier()
         }
   }
   
   private var getImageURL : URL? {
      URL(string : AppEnvironment.baseURL + imageURL)
   }
   
   private func getImageModifier() async {
      let token = await UserDefaultsRepository.shared.getValue(.accessToken)
      let headers = [
         AppEnvironment.contentTypeKey : "image/png",
         AppEnvironment.secretKey : AppEnvironment.secret,
         AppEnvironment.authorizationKey : token
      ]
      let modifier = AnyModifier { req in
         var request = req
         for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
         }
         return request
      }
      imageModifier = modifier
   }
}
