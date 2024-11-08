// hankyeol-dev.

import SwiftUI
import Combine
import AuthenticationServices

struct LoginView : View {
   @StateObject var viewModel : ViewModel

   var body: some View {
      VStack {
         Spacer()
         Text("로그인이나 회원가입을 해보자구요~")
            .font(.fwT1)
         Spacer()
         FWRoundedButton(title: "Freeworkers 시작하기") {
            viewModel.send(action: .displayLoginSheet)
         }
         Spacer.height(50.0)
      }
      .sheet(item: $viewModel.sheetConfig) { config in
         switch config {

         case .loginSheet:
            VStack(alignment : .center, spacing: 12.0) {
               SignInWithAppleButton(.signIn) { request in
                  // 1. request 할 정보를 지정해준다.
                  request.requestedScopes = [.fullName, .email]
               } onCompletion: { result in
                  viewModel.send(action: .loginWithApple(result: result))
               }
               .frame(height: 44.0)
               .padding(.horizontal, 8.0)
               
               FWRoundedButton(
                  title: "이메일로 계속하기",
                  height: 44.0,
                  background: .primary
               ) {
                  viewModel.send(action: .displayLoginFormSheet)
               }
               .padding(.bottom, 15.0)
               
               HStack(spacing: 8.0) {
                  Text("또는")
                     .font(.fwBold)
                  Button {
                     
                  } label: {
                     Text("이메일로 시작하기")
                        .font(.fwBold)
                        .foregroundStyle(Color.primary)
                  }
               }
            }
            .padding()
            .presentationDetents([.height(240.0)])
            .presentationDragIndicator(.visible)
            
         case .loginFormSheet:
            VStack(spacing: 25.0) {
               VStack(alignment : .center) {
                  Text("로그인 하기")
                     .font(.fwT2)
                     .padding(.top, 25.0)
                     .padding(.bottom, 15.0)
               }
               .frame(maxWidth: .infinity, alignment: .center)
               .background(Color.white)
               .shadow(color: Color.gray.opacity(0.4), radius: 0.4, y: 1)
               
               VStack(spacing: 10.0) {
                  Text("이메일")
                     .fwTextFieldLabelStyle(foregroundBinder: $viewModel.isValidEmail,
                                            primary: Color.primary,
                                            secondary: .error)
                     .onChange(of: viewModel.emailFieldText) { _, newValue in
                        viewModel.send(action: .validEmail(email: newValue))
                     }
                  TextField(
                     "이메일을 입력해주세요. (ex. abc@gmail.com)",
                     text: $viewModel.emailFieldText)
                  .textFieldStyle(FWTextFieldStyle(keyboardType: .emailAddress))
               }
               .padding(.horizontal, 24.0)
               
               VStack(spacing: 10.0) {
                  Text("비밀번호")
                     .font(.fwT2)
                     .foregroundStyle(viewModel.isValidPassword ? Color.primary : .error)
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .onChange(of: viewModel.passwordFieldText) { _, newValue in
                        viewModel.send(action: .validPassword(password: newValue))
                     }
                  
                  SecureField(
                     "비밀번호 (구성. 대문자, 소문자, 숫자, 기호 포함 8자 이상)",
                     text: $viewModel.passwordFieldText)
                  .textFieldStyle(FWTextFieldStyle(keyboardType: .default))
               }
               .padding(.horizontal, 24.0)
               
               Spacer.height(5.0)
               
               FWRoundedButton(title: "Freeworkers 들어가기",
                               background: viewModel.canLogin ? Color.primary : Color.gray,
                               disabled: !viewModel.canLogin
               ) {
                  viewModel.send(action: .login)
               }
               
               Spacer()
            }
            .background(Color.bg)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .displayFWToastView(toast: $viewModel.loginToast)
         }
      }
   }
}

extension LoginView {
   final class ViewModel : ViewModelType {
      private let diContainer: DIContainer

      var store: Set<AnyCancellable> = .init()
      var isLoginedHandler: (() -> Void)?
      
      init(diContainer : DIContainer, isLoginedHandler: @escaping () -> Void) {
         self.diContainer = diContainer
         self.isLoginedHandler = isLoginedHandler
      }
      
      @Published var sheetConfig : SheetConfig?
      @Published var emailFieldText : String = ""
      @Published var passwordFieldText : String = ""
      @Published var isValidEmail : Bool = true
      @Published var isValidPassword : Bool = true
      @Published var canLogin : Bool = false
      @Published var loginToast : FWToast.FWToastType?
      
      enum SheetConfig: Int, Identifiable {
         case loginSheet
         case loginFormSheet
         
         var id : Int { return self.rawValue }
      }

      enum Action {
         case displayLoginSheet
         case displayLoginFormSheet
         case login
         case loginWithApple(result : Result<ASAuthorization, any Error>)
         case validEmail(email : String)
         case validPassword(password : String)
         case canLogin
         case loginSuccess
         case loginFailed(_ message: String)
      }
      
      func send(action: Action) {
         switch action {
         case .displayLoginSheet:
            sheetConfig = .loginSheet
         case .displayLoginFormSheet:
            sheetConfig = .loginFormSheet
         case .login:
            Task {
               await login()
            }
         case let .loginWithApple(result):
            Task {
               await loginWithApple(result)
            }
         case let .validEmail(email):
            validEmail(email)
         case let .validPassword(password):
            validPassword(password)
         case .canLogin:
            validCanLogin()
         case .loginSuccess:
            loginSuccess()
         case let .loginFailed(message):
            loginFailed(message)
         }
      }
   }
}

extension LoginView.ViewModel {
   fileprivate func login() async {
      if canLogin {
         let input : LoginInputType = .init(email: emailFieldText, password: passwordFieldText)
         await diContainer.services.authService.login(input: input)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] serviceError in
               if case let .failure(errors) = serviceError {
                  self?.send(action: .loginFailed(errors.errorMessage))
               }
            } receiveValue: { [weak self] loginSuccess in
               self?.send(action: .loginSuccess)
            }
            .store(in: &store)
      }
   }
   
   fileprivate func validEmail(_ email: String) {
      isValidEmail = diContainer.services.validateService.validateEmail(email)
      send(action: .canLogin)
   }
   
   fileprivate func validPassword(_ password : String) {
      isValidPassword = diContainer.services.validateService.validatePassword(password)
      send(action: .canLogin)
   }
   
   fileprivate func validCanLogin() {
      canLogin = isValidEmail && isValidPassword && !emailFieldText.isEmpty && !passwordFieldText.isEmpty
   }
   
   fileprivate func loginSuccess() {
      sheetConfig = nil
      isLoginedHandler?()
   }
   
   fileprivate func loginFailed(_ message: String) {
      loginToast = .error(message: message, duration: 1.5)
   }
   
   fileprivate func loginWithApple(_ result: Result<ASAuthorization, Error>) async {
      if case let .success(auth) = result {
         await diContainer.services.authService.loginWithApple(authorization: auth)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loginWithAppleError in
               if case let .failure(error) = loginWithAppleError {
                  self?.loginToast = .error(message: error.errorMessage, duration: 1.5)
               }
            } receiveValue: { [weak self] loginWithAppleSuccess in
               self?.send(action: .loginSuccess)
            }
            .store(in: &store)
      }
      
      if case .failure = result {
         loginToast = .error(message: errorText.ERROR_LOGIN_WITH_APPLE, duration: 1.5)
      }
   }
}
