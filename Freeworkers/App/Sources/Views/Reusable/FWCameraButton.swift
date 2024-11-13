// hankyeol-dev.

import SwiftUI

struct FWCameraButton : View {
   var body: some View {
      Circle()
         .fill(.black)
         .overlay {
            Image(systemName: "camera.fill")
               .resizable()
               .frame(width: 8.0, height: 6.0)
               .foregroundStyle(.white)
         }
         .frame(width: 18.0, height: 18.0)
   }
}
