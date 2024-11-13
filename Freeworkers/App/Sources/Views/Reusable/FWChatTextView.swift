// hankyeol-dev.

import UIKit
import SwiftUI

struct FWChatTextView : UIViewRepresentable {
   @Binding var text : String
   @Binding var height : CGFloat
   let placeholder : String
   
   private let maxHeight : CGFloat = 90.0
   private let placeholderColor : Color = .black.opacity(0.6)
   
   func makeUIView(context: Context) -> UITextView {
      let view = UITextView()
      view.layer.cornerRadius = 10.0
      view.layer.masksToBounds = true
      view.text = placeholder
      view.textColor = UIColor(placeholderColor)
      view.backgroundColor = .clear
      view.font = .systemFont(ofSize: 13, weight: .medium)
      view.isScrollEnabled = true
      view.isEditable = true
      view.isUserInteractionEnabled = true
      view.textContainer.lineFragmentPadding = 0.0
      // view.textContainerInset = .init(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
      
      view.delegate = context.coordinator
      return view
   }
   
   func updateUIView(_ textView: UITextView, context: Context) {
      updateHeight(textView)
   }
   
   func makeCoordinator() -> Coordinator {
      return Coordinator(delegate: self)
   }
   
   private func updateHeight(_ textView : UITextView) {
      let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
      DispatchQueue.main.async {
         if size.height <= maxHeight {
            height = size.height
         }
      }
   }
}

extension FWChatTextView {
   final class Coordinator : NSObject, UITextViewDelegate {
      var delegate: FWChatTextView
      
      init(delegate: FWChatTextView) {
         self.delegate = delegate
      }
      
      func textViewDidChange(_ textView: UITextView) {
         delegate.text = textView.text
         
         if textView.text.isEmpty {
            textView.textColor = UIColor(delegate.placeholderColor)
         } else {
            textView.textColor = UIColor(.black)
         }
        
         delegate.updateHeight(textView)
      }
      
      func textViewDidBeginEditing(_ textView: UITextView) {
         if textView.text == delegate.placeholder {
            textView.text = ""
         }
      }
      
      func textViewDidEndEditing(_ textView: UITextView) {
         if textView.text.isEmpty {
            textView.text = delegate.placeholder
         }
      }
   }
}
