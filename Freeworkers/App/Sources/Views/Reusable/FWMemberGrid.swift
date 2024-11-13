// hankyeol-dev.

import SwiftUI

struct FWMemberGrid : View {
   var memberList : [UserCommonOutputType]
   var tapAction : (String) -> Void
   
   var body: some View {
      LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5), spacing: 15.0) {
         ForEach(memberList, id: \.user_id) { member in
            FMMemberGridItem(member: member)
               .onTapGesture {
                  tapAction(member.user_id)
               }
         }
      }
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
            .frame(width: 36.0, height: 36.0)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
         Text(member.nickname)
            .font(.fwRegular)
            .lineLimit(2)
      }
//      .frame(width: 40.0, height: 40.0)
      .padding(5.0)
   }
}
