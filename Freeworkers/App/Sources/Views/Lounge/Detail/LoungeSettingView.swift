// hankyeol-dev.

import SwiftUI

struct LoungeSettingView : View {
   @StateObject var viewModel : LoungeSettingViewModel
   
   var body: some View {
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
               LoungeSettingRow(title: buttonTitle.INVITE_LOUNGE) {
                  viewModel.send(action: .tapMenu(type: .invite))
               }
               
               if viewModel.isOwned {
                  LoungeSettingRow(title: buttonTitle.EDIT_LOUNGE) { print("") }
                  LoungeSettingRow(title: buttonTitle.CHANGE_LOUNGE_OWNER) { print("") }
                  LoungeSettingRow(title: buttonTitle.DELETE_LOUNGE, color: .error) { print("") }
               } else {
                  LoungeSettingRow(title: buttonTitle.LEAVE_LOUNGE, color: .error) { print("") }
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
                     print(memberId)
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
   }
}
