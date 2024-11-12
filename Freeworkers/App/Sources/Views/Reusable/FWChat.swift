// hankyeol-dev.

import SwiftUI
import FreeworkersDBKit

struct FWChat : View {
   private let chat : Chat
   /**
    - 프로필 이미지 - 프로필 이름
    - 채팅
    - 이미지 있다면
    
    */
   
   init(chat: Chat) {
      self.chat = chat
   }
   
   var body: some View {
      HStack {
         if !chat.me {
            profileImage
         }
         if chat.me {
            Spacer()
            chatCreatedAt
         }
         
         chatView
         
         if !chat.me {
            chatCreatedAt
            Spacer()
         }
      }
      .frame(maxWidth: .infinity, alignment: chat.me ? .topTrailing : .topLeading)
   }
   
   @ViewBuilder
   var profileImage : some View {
      VStack {
         if let profileImage = chat.userProfileImage {
            FWImage(imagePath: profileImage)
               .frame(width: 36.0, height: 36.0)
               .clipShape(RoundedRectangle(cornerRadius: 10.0))
         } else {
            Image(systemName: "person.circle")
               .resizable()
               .frame(width: 32.0, height: 32.0)
         }
         
         Spacer()
      }
   }
   
   @ViewBuilder
   var chatView : some View {
      VStack(alignment: chat.me ? .trailing : .leading, spacing: 8.0) {
         if !chat.me {
            Text(chat.username)
               .font(.fwRegular)
               .foregroundStyle(.gray.opacity(1.5))
               .frame(alignment: .leading)
         }
         
         if !chat.content.isEmpty {
            Text(chat.content)
               .font(.fwT2)
               .padding(.horizontal, 12.0)
               .padding(.vertical, 10.0)
               .foregroundColor(chat.me ? .white : .black)
               .background(chat.me ? .black : Color.bg)
               .clipShape(RoundedRectangle(cornerRadius: 10.0))
         }
         
         if !chat.files.isEmpty {
            
         }
         
         Spacer()
      }
//      .frame(maxWidth: 250.0, alignment: chat.me ? .trailing : .leading)
      .padding(chat.me ? .trailing : .leading, 5.0)
   }
   
   @ViewBuilder
   var chatCreatedAt : some View {
      VStack {
         Spacer()
         Text(chat.createdAt.toISO860().toChatDate())
            .font(.system(size: 10.0, weight: .thin))
            .foregroundStyle(.black.opacity(0.8))
         Spacer.height(15.0)
      }
   }
}
