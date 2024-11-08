// hankyeol-dev.

import SwiftUI
import Kingfisher

struct LoungeHomeView : View {
   @EnvironmentObject var diContainer : DIContainer
   @StateObject var viewModel : LoungeHomeViewModel
   
   var body: some View {
      NavigationStack(path : $diContainer.navigator.destination) {
         VStack {
            VStack(alignment: .leading) {
               LoungeListView(viewModel: viewModel)
            }
            
            Spacer()
            
            FWRoundedButton(title: buttonTitle.DISPLAY_CREATE_FREEWORKER_ROUNGE_SHEET) {
               viewModel.send(action: .createLounge)
            }
            
            Spacer.height(20.0)
         }
         .navigationTitle("프리워커스 라운지")
         .navigationBarTitleDisplayMode(.inline)
         .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
               FWImage(
                  imageURL: viewModel.profileImage,
                  width: 20.0, height: 20.0
               ) {
                  Image(systemName: "person.circle")
                     .resizable()
                     .frame(width: 20.0, height: 20.0)
               }
               .clipShape(Circle())
               .onTapGesture {
                  viewModel.send(action: .pushToProfile)
               }
            }
         }
         .sheet(item: $viewModel.sheetConfig, onDismiss: {
            viewModel.send(action: .getLounges)
         }) { config in
            if case .displayCreateLounge = config {
               CreateLoungeView(
                  viewModel: .init(diContainer: diContainer, handler: { viewModel.sheetConfig = nil }))
                  .presentationDragIndicator(.visible)
                  .presentationDetents([.large])
            }
         }
         .task {
            viewModel.send(action: .getMe)
            viewModel.send(action: .getLounges)
         }
         .navigationDestination(for: NavigationDestination.self) { destination in
            RoutingView(destination: destination)
         }
      }
   }
}

fileprivate struct LoungeListView : View {
   @ObservedObject fileprivate var viewModel : LoungeHomeViewModel
   
   var body: some View {
      ScrollView(.vertical) {
         LazyVStack {
            ForEach(viewModel.userLoungeList, id: \.loungeId) { lounge in
               HStack {
                  FWImage(imageURL: lounge.coverImage, width: 36.0, height: 36.0) {
                     Image(.photoIcon)
                        .resizable()
                        .frame(width: 36.0, height: 36.0)
                  }
                  .clipShape(RoundedRectangle(cornerRadius: 10.0))
                  
                  VStack (alignment : .leading) {
                     Text(lounge.loungeName)
                        .font(.fwT2)
                     Spacer()
                     if let description = lounge.description {
                        Text(description)
                           .font(.fwRegular)
                     }
                  }
                  
                  Spacer()
                  
                  Image(systemName: "arrow.right")
                     .resizable()
                     .frame(width: 10.0, height: 10.0)
                     .foregroundStyle(.black)
               }
               .padding()
               .background(Color.primary)
               .onTapGesture {
                  viewModel.send(action: .pushToLounge(loungeId: lounge.loungeId))
               }
               Divider()
            }
         }
      }
   }
}

