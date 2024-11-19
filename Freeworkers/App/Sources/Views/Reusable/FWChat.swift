// hankyeol-dev.

import SwiftUI
import FreeworkersDBKit

struct FWChat : View {
   private let chat : Chat
   private var imageTapHandler : (Int) -> Void
   private var profileTapHandler : (Chat) -> Void

   @State private var isTruncated : Bool = false
   @State private var isTappedExpand : Bool = false
   
   init(chat: Chat,
        imageTapHandler : @escaping (Int) -> Void,
        profileTapHandler : @escaping (Chat) -> Void
   ) {
      self.chat = chat
      self.imageTapHandler = imageTapHandler
      self.profileTapHandler = profileTapHandler
   }
   
   var body: some View {
      HStack {
         if !chat.me {
            profileImage
               .onTapGesture {
                  profileTapHandler(chat)
               }
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
            VStack(alignment: .leading,  spacing: 5.0) {
               Text(chat.content)
                  .font(.fwRegular)
                  .padding(.horizontal, 12.0)
                  .padding(.vertical, 10.0)
                  .lineLimit(isTappedExpand ? nil : 3)
                  .foregroundColor(chat.me ? .white : .black)
                  .background(GeometryReader { geometry in
                     chat.me ? Color.black.onAppear {
                        estimateTruncation(geometry)
                     } : Color.bg.onAppear {
                        estimateTruncation(geometry)
                     }
                  })
               if isTruncated {
                  Button {
                     isTappedExpand.toggle()
                  } label: {
                     Text(isTappedExpand ? "줄여서 보기" : "전체 확인하기")
                        .font(.fwCaption)
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 12.0)
                        .padding(.bottom, 10.0)
                  }
               }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
         }
         
         if !chat.files.isEmpty {
            chatImageGrid
         }
         
         Spacer()
      }
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
   
   @ViewBuilder
   var chatImageGrid : some View {
      let maxWidth : CGFloat = 220
      let counts : Int = chat.files.count
      let maxCounts : Int = counts >= 3 ? 3 : counts
      let columns = Array(repeating: GridItem(.flexible(minimum: 70.0, maximum: 160.0),
                                              spacing: 10.0),
                          count: maxCounts)
      
      if counts == 1 {
         FWImage(imagePath: chat.files[0])
            .frame(width: 130.0, height: 130.0)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .onTapGesture {
               withAnimation(.easeInOut) {
                  imageTapHandler(0)
               }
            }
      } else {
         HStack {
            if chat.me {
               Spacer()
            }
            LazyVGrid(columns: columns, alignment: .center) {
               ForEach(chat.files.indices, id:\.self) { index in
                  Button {
                     withAnimation(.easeInOut) {
                        imageTapHandler(index)
                     }
                  } label: {
                     ZStack {
                        let width : CGFloat = counts == 0
                        ? 0
                        : counts == 1
                        ? 150.0 : (maxWidth) / CGFloat(maxCounts)
                        
                        if index < 3 {
                           FWImage(imagePath: chat.files[index])
                              .frame(width: width, height: width)
                              .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        }
                        if counts > 3 && index == 2 {
                           RoundedRectangle(cornerRadius: 10.0)
                              .fill(.black.opacity(0.5))
                              .frame(width: width, height: width)
                              .overlay {
                                 Text("+ \(counts - 3)")
                                    .font(.fwT1)
                                    .foregroundStyle(.white)
                              }
                        }
                     }
                  }
               }
            }
            if !chat.me {
               Spacer()
            }
         }
         .frame(width: maxWidth + 20)
      }
   }
}

extension FWChat {
   private func estimateTruncation(_ geometry : GeometryProxy) {
      let text = chat.content
      if !text.isEmpty {
         let total = text.boundingRect(
            with: .init(width: geometry.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil)
         if total.size.height > geometry.size.height {
            isTruncated = true
         }
      }
   }
}
