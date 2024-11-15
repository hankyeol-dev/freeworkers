// hankyeol-dev.

import SwiftUI

struct FWMemberGrid : View {
   var memberList : [UserCommonOutputType]
   var tapAction : (String) -> Void
   
   var body: some View {
      LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5), alignment: .center, spacing: 15.0) {
         ForEach(memberList, id: \.user_id) { member in
            FMMemberGridItem(member: member)
               .onTapGesture {
                  tapAction(member.user_id)
               }
         }
      }.padding(10.0)
   }
}

fileprivate struct FMMemberGridItem : View {
   fileprivate let member: UserCommonOutputType
   
   fileprivate init(member: UserCommonOutputType) {
      self.member = member
   }
   
   var body: some View {
      VStack(alignment: .center, spacing: 13.0) {
         FWImage(imagePath: member.profileImage ?? "/", placeholderImageName: "person.circle")
            .frame(width: 44.0, height: 44.0)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
         Text(member.nickname)
            .font(.fwCaption)
            .lineLimit(1)
      }
      .frame(width: 50.0, height: 50.0)
      .padding(5.0)
   }
}
