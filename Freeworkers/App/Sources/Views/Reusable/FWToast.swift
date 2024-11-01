// hankyeol-dev.

import UIKit
import SwiftUI

struct FWToast : View {
   private var toastType : FWToastType
   
   init(toastType: FWToastType) {
      self.toastType = toastType
   }
   
   var body: some View {
      RoundedRectangle(cornerRadius: 8.0)
         .fill(toastType.bgColor)
         .frame(height: 40.0)
         .overlay {
            Text(toastType.toastMessage)
               .font(.fwCaption)
               .foregroundStyle(toastType.fgColor)
         }
         .padding(.horizontal, 30.0)
   }
}

extension FWToast {
   enum FWToastType : Equatable {
      case error(message : String, duration : Double)
      case success(message : String, duration : Double)
      
      var bgColor : Color {
         switch self {
         case .error:
            return Color.error
         case .success:
            return Color.primary
         }
      }
      
      var fgColor : Color { return .white }
      
      var toastMessage : String {
         switch self {
         case let .error(message, _):
            return message
         case let .success(message, _):
            return message
         }
      }
      
      var toastDuration : Double {
         switch self {
         case let .error(_, duration):
            return duration
         case let .success(_, duration):
            return duration
         }
      }
   }
}

struct FWToastModifier : ViewModifier {
   
   @Binding var toast : FWToast.FWToastType?
   @State private var toastTask : Task<Void, Never>?
   
   func body(content: Content) -> some View {
      content
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .overlay {
            ZStack {
               makeFWToastView()
                  .offset(y: -30.0)
            }
            .animation(.spring, value: toast)
         }
         .onChange(of: toast) { _, _ in
            displayToast()
         }
   }
   
   @ViewBuilder
   func makeFWToastView() -> some View {
      if let toast {
         VStack {
            Spacer()
            FWToast(toastType: toast)
         }
         .transition(.move(edge: .bottom))
      }
   }
   
   @MainActor
   private func displayToast() {
      guard let toast else { return }
      
      // MARK: HapticFeedback
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      
      if toast.toastDuration > 0.0 {
         toastTask?.cancel()
         
         DispatchQueue.main.asyncAfter(deadline: .now() + toast.toastDuration) {
            toastTask = Task {
               dismissToast()
            }
         }
      }
   }
   
   @MainActor
   private func dismissToast() {
      withAnimation {
         toast = nil
      }
      toastTask?.cancel()
      toastTask = nil
   }
}
