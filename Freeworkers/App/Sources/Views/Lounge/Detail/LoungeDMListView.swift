// hankyeol-dev.

import SwiftUI

struct LoungeDMListView : View {
   @EnvironmentObject var diContainer : DIContainer
   @StateObject var viewModel : LoungeDMListViewModel
   
   var body: some View {
      NavigationStack(path: $diContainer.navigator.destination) {
         VStack {
            header
            memberList
            FWSectionDivider(height: 10.0)
            dmList
            Spacer()
         }
         .displayFWToastView(toast: $viewModel.toastConfig)
         .task {
            if diContainer.hideTab { diContainer.toggleTab() }
            viewModel.send(action: .didLoad)
         }
         .navigationDestination(for: NavigationDestination.self) { destination in
            RoutingView(destination: destination)
         }
      }
   }
   
   @ViewBuilder
   private var header : some View {
      HStack {
         Text(workspaceTitle.LOUNGE_DM_LIST)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .center)
      }
      .padding()
      .background(Color.bg)
      .frame(height: 40.0)
   }
   
   @ViewBuilder
   private var memberList : some View {
      ScrollView(.horizontal) {
         LazyHStack {
            let members = viewModel.loungeMembers
            ForEach(members.indices, id: \.self) { index in
               VStack(alignment: .center, spacing: 10.0) {
                  FWImage(imagePath: members[index].profileImage ?? "/")
                     .frame(width: 50.0, height: 50.0)
                     .clipShape(RoundedRectangle(cornerRadius: 10.0))
                  Text(members[index].nickname)
                     .font(.fwCaption)
                     .foregroundStyle(.black)
               }
               .padding(.horizontal, 5.0)
               .frame(width: 70.0)
               .onTapGesture {
                  viewModel.send(action: .pushToDM(user: members[index]))
               }
            }
         }
      }
      .frame(height: 80.0)
      .frame(maxWidth: .infinity)
      .scrollIndicators(.hidden)
      .padding()
   }
   
   @ViewBuilder
   private var dmList : some View {
      ScrollView(.vertical) {
         LazyVStack {
            let dms = viewModel.loungeDMList
            ForEach(dms.indices, id: \.self) { index in
               let dm = dms[index]
               HStack(alignment : .center) {
                  FWImage(imagePath: dm.dmViewItem.opponent.profileImage ?? "/")
                     .frame(width: 40.0, height: 40.0)
                     .clipShape(RoundedRectangle(cornerRadius: 10.0))
                
                  Spacer.width(20.0)
                  
                  VStack(alignment : .leading, spacing: 5.0) {
                     Text(dm.dmViewItem.opponent.nickname)
                        .font(.fwCaption)
                        .foregroundStyle(.black)
                     Text(dm.lastDM)
                        .font(.fwCaption)
                        .foregroundStyle(.gray.opacity(1.5))
                        .lineLimit(1)
                  }
                  
                  Spacer()

                  if dm.unreads != 0 {
                     RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color.primary)
                        .frame(width: 30.0, height: 20.0)
                        .overlay {
                           Text(dm.unreads > 99 ? "+99" : "\(dm.unreads)")
                              .font(.fwCaption)
                              .foregroundStyle(.white)
                        }
                  }
               }
               .onTapGesture {
                  viewModel.send(action: .pushToDM(user: dm.dmViewItem.opponent))
               }
            }
         }
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.horizontal, 20.0)
      .padding(.top, 10.0)
   }
}
