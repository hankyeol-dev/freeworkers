// hankyeol-dev.

import SwiftUI
import PhotosUI

struct LoungeSettingView : View {
   @EnvironmentObject var diContainer : DIContainer
   @StateObject var viewModel : LoungeSettingViewModel
   
   var body: some View {
      NavigationStack(path: $diContainer.navigator.destination) {
         VStack {
            HStack {
               Text(workspaceTitle.LOUNGE_SETTING)
                  .foregroundStyle(.black)
                  .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background(Color.bg)
            .frame(height: 40.0)
            
            ScrollView(.vertical) {
               VStack(alignment: .leading, spacing: 20.0) {
                  if viewModel.isOwned {
                     LoungeSettingRow(title: buttonTitle.INVITE_LOUNGE) {
                        viewModel.send(action: .tapMenu(type: .invite))
                     }
                     LoungeSettingRow(title: buttonTitle.EDIT_LOUNGE) {
                        viewModel.send(action: .tapMenu(type: .edit))
                     }
                     LoungeSettingRow(title: buttonTitle.CHANGE_LOUNGE_OWNER) {
                        viewModel.send(action: .tapMenu(type: .changeOwnership))
                     }
                     LoungeSettingRow(title: buttonTitle.DELETE_LOUNGE, color: .error) { print("") }
                  } else {
                     LoungeSettingRow(title: buttonTitle.LEAVE_LOUNGE, color: .error) {
                        viewModel.displayLeavePopup = true
                     }
                  }
               }
               .padding(.horizontal, 20.0)
               .padding(.vertical, 20.0)
               
               FWSectionDivider(height: 10.0)
               
               LazyVStack(spacing: 15.0) {
                  FWFlipedHeader(
                     toggleCondition: $viewModel.loungeMemberListToggle,
                     HeaderTitle: viewModel.getLoungeName() + workspaceTitle.LOUNGE_MEMBERS
                  ) { viewModel.send(action: .tapMemeberListToggle) }
                  
                  if viewModel.loungeMemberListToggle {
                     FWMemberGrid(memberList: viewModel.loungeMembers) { memberId in
                        viewModel.send(action: .pushToProfile(userId: memberId))
                     }
                  }
               }
               .padding(.top, 15.0)
               
               Spacer()
            }
         }
         .task {
            viewModel.send(action: .didLoad)
         }
         .sheet(item: $viewModel.sheetConfig) { type in
            if case .invite = type {
               LoungeInviteView(viewModel: viewModel)
                  .presentationDetents([.fraction(0.3)])
                  .presentationDragIndicator(.visible)
            }
            
            if case .edit = type {
               LoungeEditView(viewModel: viewModel)
                  .presentationDetents([.large])
                  .presentationDragIndicator(.visible)
            }
            
            if case .changeOwnership = type {
               LoungeChangeOwnerView(viewModel: viewModel)
                  .presentationDetents([.large])
                  .presentationDragIndicator(.visible)
            }
         }
         .overlay {
            if viewModel.displayLeavePopup {
               FWCentreConfirm(
                  header: "프리워커스 라운지 나가기",
                  content: ["정말 이 라운지를 떠나시겠습니까?"],
                  cancelTitle: buttonTitle.LEAVE_LOUNGE_CANCEL,
                  confirmTitle: buttonTitle.LEAVE_LOUNGE_CONFIRM
               ) {
                  viewModel.displayLeavePopup = false
               } confirmAction: {
                  viewModel.send(action: .exit)
               }
               .transition(.move(edge: .bottom))
            }
            
            if let message = viewModel.displayLeaveErrorMessage {
               FWCentreConfirm(
                  header: "프리워커스 라운지 나가기",
                  content: [message], 
                  cancelTitle: "확인",
                  confirmTitle: "",
                  isConfirm: false) {
                     viewModel.displayLeaveErrorMessage = nil
                  } confirmAction: {}
            }
         }
         .navigationDestination(for: NavigationDestination.self) { destination in
            RoutingView(destination: destination)
         }
      }
   }
}

fileprivate struct LoungeSettingRow : View {
   private let title : String
   private let color : Color
   private var onTapAction : () -> Void
   
   init(title: String, color : Color = .black, onTapAction: @escaping () -> Void) {
      self.title = title
      self.color = color
      self.onTapAction = onTapAction
   }
   
   var body: some View {
      HStack(alignment: .center, spacing: 10.0) {
         Text(title)
            .font(.system(size: 15.0, weight: .regular))
            .foregroundStyle(color)
         Spacer()
      }
      .padding(.vertical, 5.0)
      .onTapGesture {
         onTapAction()
      }
   }
}

fileprivate struct LoungeInviteView : View {
   @State private var textBinder : Bool = true
   @ObservedObject fileprivate var viewModel : LoungeSettingViewModel
   
   var body: some View {
      VStack(alignment: .center, spacing: 20.0) {
         Spacer.height(20.0)
         VStack {
            Text(workspaceTitle.LOUNGE_INVITE_TITLE)
               .fwTextFieldLabelStyle(foregroundBinder: $textBinder,
                                      primary: .black,
                                      secondary: .black)
            TextField(placeholderText.INVITE_LOUNGE, text: $viewModel.inviteEmail)
               .textFieldStyle(FWTextFieldStyle(keyboardType: .emailAddress))
               .onChange(of: viewModel.inviteEmail) { _, _ in
                  viewModel.send(action: .validEmail)
               }
         }
         .padding(.horizontal, 24.0)
         FWRoundedButton(title: buttonTitle.INVITE_LOUNGE,
                         background: viewModel.validEmail ? Color.primary : .gray,
                         disabled: !viewModel.validEmail) {
            viewModel.send(action: .invite)
         }
         Spacer()
      }
      .background(Color.bg)
      .displayFWToastView(toast: $viewModel.toastConfig)
      .onDisappear {
         viewModel.send(action: .invite)
      }
   }
}

fileprivate struct LoungeEditView : View {
   @ObservedObject fileprivate var viewModel : LoungeSettingViewModel
   @State private var photoSelection : [PhotosPickerItem] = []
   @State private var nameBinder : Bool = true
   @State private var descriptionBinder : Bool = true
   
   var body: some View {
      VStack(alignment: .center, spacing: 20.0) {
         Spacer.height(20.0)
                  
         VStack {
            PhotosPicker(selection : $photoSelection,
                         maxSelectionCount: 1,
                         selectionBehavior: .default,
                         matching: .images
            ) {
               ZStack {
                  RoundedRectangle(cornerRadius: 5.0)
                     .stroke(lineWidth: 0.8)
                     .foregroundStyle(.black)
                     .frame(width: 80.0, height: 80.0)
                  
                  if let item = viewModel.changedImage, let image = item.0 {
                     Image(uiImage: image)
                        .resizable()
                        .frame(width: 72.0, height: 72.0)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                  } else {
                     FWImage(imagePath: viewModel.loungeImage)
                        .frame(width: 72.0, height: 72.0)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                  }
                  Circle()
                     .fill(.black)
                     .overlay {
                        Image(systemName: "camera.fill")
                           .resizable()
                           .frame(width: 12.0, height: 10.0)
                           .foregroundStyle(.white)
                     }
                     .frame(width: 25.0, height: 25.0)
                     .padding(.leading, 72.0)
                     .padding(.top, 72.0)
               }
            }
            .onChange(of: photoSelection) { _, newValue in
               setLoungeImage(newValue)
            }
         }.padding()
         
         VStack {
            Text(workspaceTitle.CREATE_ROUNGE_NAME_LABEL)
               .fwTextFieldLabelStyle(foregroundBinder: $nameBinder,
                                      primary: .black,
                                      secondary: .black)
            TextField(placeholderText.CREATE_ROUNGE_NAME, text: $viewModel.loungeName)
               .textFieldStyle(FWTextFieldStyle(keyboardType: .default))
         }
         .padding(.horizontal, 20.0)
         
         VStack {
            Text(workspaceTitle.CREATE_ROUNGE_DESCRIPTION_LABEL)
               .fwTextFieldLabelStyle(foregroundBinder: $descriptionBinder,
                                      primary: .black,
                                      secondary: .black)
            TextField(placeholderText.CREATE_ROUNGE_DESCRIPTION, text: $viewModel.loungeDescription)
               .textFieldStyle(FWTextFieldStyle(keyboardType: .default))
         }
         .padding(.horizontal, 20.0)
         
         FWRoundedButton(title: buttonTitle.MODIFY_LOUNGE) {
            viewModel.send(action: .edit)
         }
         
         Spacer()
      }
      .background(Color.bg)
      .displayFWToastView(toast: $viewModel.toastConfig)
      .onDisappear {
         viewModel.send(action: .tapMenuReset(type: .edit))
      }
   }
   
   private func setLoungeImage(_ items: [PhotosPickerItem])  {
      for item in items {
         item.loadTransferable(type: Data.self) { result in
            switch result {
            case let .success(data):
               if let data,
                  let uiImage = UIImage(data: data),
                  let imageData = uiImage.downscaleTOjpegData(maxBytes: 1_000_000) {
                  viewModel.send(action: .setImage(image: uiImage, imageData: imageData))
               }
            default:
               break
            }
         }
      }
   }
}

fileprivate struct LoungeChangeOwnerView : View {
   @ObservedObject fileprivate var viewModel : LoungeSettingViewModel
   
   init(viewModel: LoungeSettingViewModel) {
      self.viewModel = viewModel
   }
   
   var body: some View {
      VStack(spacing: 20.0) {
         if viewModel.loungeMembers.isEmpty {
            Text(appTexts.LOUNGE_NO_MEMBERS)
               .font(.fwRegular)
            
         } else {
            Spacer.height(20.0)
                        
            let members = viewModel.loungeMembers
            ScrollView(.vertical) {
               LazyVStack {
                  ForEach(members.indices, id:\.self) { index in
                     let member = members[index]
                     HStack(spacing : 10.0) {
                        FWImage(imagePath: member.profileImage ?? "/")
                           .frame(width: 50.0, height: 50.0)
                           .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        
                        VStack(alignment: .leading, spacing: 5.0) {
                           Text(member.nickname)
                              .font(.fwRegular)
                              .foregroundStyle(.black)
                           Text(member.email)
                              .font(.fwCaption)
                              .foregroundStyle(.gray.opacity(1.5))
                        }
                        Spacer()
                     }
                     .frame(height: 60.0)
                     .onTapGesture {
                        viewModel.send(action: .setOwner(member: member))
                     }
                  }
               }
            }
            .padding(.horizontal, 20.0)
            
            Spacer()
         }
      }
      .background(Color.bg)
      .overlay {
         if viewModel.selectedMember != nil {
            FWCentreConfirm(
               header: "선택한 프리워커를 관리자로 변경합니다.",
               content: ["라운지 관리자는 다음과 같은 권한이 있습니다.", "- 라운지 이름 또는 설명 변경", "- 라운지 삭제", "- 라운지 멤버 초대"],
               cancelTitle: buttonTitle.CHANGE_OWNER_CANCEL,
               confirmTitle: buttonTitle.CHANGE_OWNER_CONFIRM
            ) {
               viewModel.send(action: .tapMenuReset(type: .changeOwnership))
            } confirmAction: {
               viewModel.send(action: .changeOwner)
            }
         }
      }
      .displayFWToastView(toast: $viewModel.toastConfig)
   }
}

