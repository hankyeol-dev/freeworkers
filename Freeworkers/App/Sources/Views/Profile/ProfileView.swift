// hankyeol-dev.

import SwiftUI

struct ProfileView : View {
   @StateObject var viewModel : ProfileViewModel
   
   var body: some View {
      VStack {
         if let profileViewItem = viewModel.profileViewItem {
            ScrollView(.vertical) {
               if viewModel.isMe {
                  Group {
                     ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 5.0)
                           .stroke(lineWidth: 0.8)
                           .foregroundStyle(.black)
                           .frame(width: 55.0, height: 55.0)
                        FWImage(imagePath: profileViewItem.profileImage ?? "/", placeholderImageName: "person.circle")
                           .frame(width: 50.0, height: 50.0)
                           .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        FWCameraButton()
                           .padding(.leading, 50.0)
                           .padding(.top, 45.0)
                           .onTapGesture {
                              
                           }
                     }
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding(.vertical, 20.0)
                     
                     ProfileBannerView(title: "내 코인") {
                        Group {
                           Spacer()
                           Text(String(profileViewItem.sesacCoin))
                              .font(.fwT2)
                              .foregroundStyle(Color.primary)
                           Text("개")
                              .font(.fwT2)
                              .foregroundStyle(.gray.opacity(1.5))
                              .padding(.leading, -5.0)
                           Spacer.width(10.0)
                           Text("충전하기")
                              .font(.fwRegular)
                              .foregroundStyle(.gray)
                           Spacer.width(10.0)
                           Image(systemName: "chevron.right")
                              .resizable()
                              .frame(width: 5.0, height: 10.0)
                        }
                     } tapAction: {
                        viewModel.send(action: .tapBanner(.fillCoin(coin: profileViewItem.sesacCoin)))
                     }
                     
                     ProfileBannerView(title: "닉네임") {
                        Group {
                           Spacer()
                           Text(profileViewItem.nickname)
                              .font(.fwRegular)
                              .foregroundStyle(.gray)
                           Spacer.width(10.0)
                           Image(systemName: "chevron.right")
                              .resizable()
                              .frame(width: 5.0, height: 10.0)
                        }
                     } tapAction: {
                        viewModel.send(action: .tapBanner(.patchNickname(nickname: profileViewItem.nickname)))
                     }.padding(.vertical, -5.0)
                     
                     ProfileBannerView(title: "전화번호") {
                        Group {
                           Spacer()
                           Text(profileViewItem.phone ?? "미등록 상태")
                              .font(.fwRegular)
                              .foregroundStyle(.gray)
                           Spacer.width(10.0)
                           Image(systemName: "chevron.right")
                              .resizable()
                              .frame(width: 5.0, height: 10.0)
                        }
                     } tapAction: {
                        viewModel.send(action: .tapBanner(.patchPhone(phone: profileViewItem.phone ?? "")))
                     }
                     
                     Spacer.height(30.0)
                     
                     ProfileBannerView(title: "이메일") {
                        Group {
                           Spacer()
                           Text(profileViewItem.email)
                              .font(.fwRegular)
                              .foregroundStyle(.gray)
                        }
                     } tapAction: { }
                     
                     ProfileBannerView(title: "연결된 소셜 계정") {
                        Group {
                           Spacer()
                           Text(profileViewItem.provider ?? "없음")
                              .font(.fwRegular)
                              .foregroundStyle(.gray)
                        }
                     } tapAction: { }.padding(.vertical, -5.0)
                     
                     ProfileBannerView(title: "로그아웃") { Text("") } tapAction: {
                        
                     }
                     
                     Spacer()
                  }
               } else {
                  Text("남의 뷰")
               }
            }
            .font(.fwT2)
            .frame(maxWidth: .infinity, alignment: .topLeading)
         } else {
            EmptyView()
         }
      }
      .padding(.horizontal, 20.0)
      .task {
         viewModel.send(action: .didLoad)
      }
   }
}

fileprivate struct ProfileBannerView<Content : View> : View {
   fileprivate var title : String
   fileprivate var background : Color
   fileprivate var contentView : () -> Content
   fileprivate var tapAction : () -> Void
   
   init(
      title: String,
      background : Color = .white,
      contentView: @escaping () -> Content,
      tapAction: @escaping () -> Void) {
         self.title = title
         self.background = background
         self.contentView = contentView
         self.tapAction = tapAction
      }
   
   var body: some View {
      RoundedRectangle(cornerRadius: 8.0)
         .fill(background)
         .shadow(color: .gray.opacity(0.3), radius: 0.5, x: 0.0, y: 0.3)
         .frame(maxWidth: .infinity, alignment: .center)
         .frame(height: 50.0)
         .overlay {
            HStack {
               Text(title)
                  .font(.fwT2)
               Spacer()
               
               contentView()
            }
            .padding()
         }
         .onTapGesture { tapAction() }
   }
}

struct ProfileFillCoinView : View {
   @EnvironmentObject var diContainer : DIContainer
   @State private var purchaseList : [(Int, Int)] = [(10, 100), (50, 500), (100, 1000)]
   @State var coin : Int
   
   var body: some View {
      VStack {
         ProfileBannerView(title: "현재 보유 코인", background: Color.bg) {
            HStack {
               Spacer()
               Text(String(coin))
                  .font(.fwT2)
                  .foregroundStyle(Color.primary)
               Text("개")
            }
         } tapAction: {}
         
         Spacer.height(25.0)
         
         ForEach(purchaseList, id: \.1) { item in
            ProfileBannerView(title: "\(item.0) 코인", background: Color.bg) {
               FWRoundedButton(
                  title: "₩ \(item.1.formatted())",
                  width: 80.0,
                  height: 36.0,
                  foreground: .white,
                  background: Color.primary
               ) {
                  
               }
            } tapAction: {}
         }
         
         Spacer()
      }
      .padding()
   }
   
}

struct ProfilePatchNicknameView : View {
   @EnvironmentObject var diContainer : DIContainer
   @State var nickname : String
   let baseNickname : String
   @FocusState var nicknameFieldFocus : Bool
   
   var body: some View {
      VStack {
         VStack(spacing: 10.0) {
            Text("닉네임")
               .font(.fwT2)
               .foregroundStyle(.black)
               .frame(maxWidth: .infinity, alignment: .leading)
               .padding(.horizontal, 25.0)
            
            TextField("닉네임은 1~29자 이내로 입려해주세요.", text: $nickname)
               .padding()
               .foregroundStyle(.black)
               .background(Color.bg)
               .tint(.black)
               .font(.fwRegular)
               .clipShape(RoundedRectangle(cornerRadius: 8.0))
               .textInputAutocapitalization(.never)
               .focused($nicknameFieldFocus)
               .padding(.horizontal, 25.0)
            
            FWRoundedButton(title: "닉네임 수정", height: 50.0) {
               Task { await patchNickname() }
            }
         }
         .padding(.top, 20.0)
         
         Spacer()
      }
      .onTapGesture { nicknameFieldFocus = false }
   }
   
   @MainActor
   func patchNickname() async {
      nicknameFieldFocus = false
      
      if (nickname != baseNickname) && (nickname.count >= 1) && (nickname.count <= 30) {
         let result = await diContainer.services.userService.putNickname(nickname: nickname)
         if case .success = result {
            diContainer.navigator.pop()
         }
         
         if case let .failure(failure) = result {
            print(failure.errorMessage)
         }
      }
   }
}

struct ProfilePatchPhoneView : View {
   @EnvironmentObject var diContainer : DIContainer
   @State var phone : String
   let basePhone : String
   @FocusState var fieldFocus : Bool
   
   var body: some View {
      VStack {
         VStack(spacing: 10.0) {
            Text("전화번호")
               .font(.fwT2)
               .foregroundStyle(.black)
               .frame(maxWidth: .infinity, alignment: .leading)
               .padding(.horizontal, 25.0)
            
            TextField("전화번호는 11자리 정확하게 입력해주세요.", text: $phone)
               .padding()
               .foregroundStyle(.black)
               .background(Color.bg)
               .tint(.black)
               .font(.fwRegular)
               .clipShape(RoundedRectangle(cornerRadius: 8.0))
               .textInputAutocapitalization(.never)
               .focused($fieldFocus)
               .padding(.horizontal, 25.0)
            
            FWRoundedButton(title: "전화번호 수정", height: 50.0) {
               Task { await patchNickname() }
            }
         }
         .padding(.top, 20.0)
         
         Spacer()
      }
      .onTapGesture { fieldFocus = false }
   }
   
   @MainActor
   func patchNickname() async {
      fieldFocus = false
      
      if (phone != basePhone) && (phone.count == 11) {
         let result = await diContainer.services.userService.putPhone(phone: phone)
         if case .success = result {
            diContainer.navigator.pop()
         }
      }
   }
}
