# Freeworkers

‘일(Work)’상에서 벗어나 나만의 라운지를 만들고, 함께하는 사람을 초대해 즐겁게 소통하는 채팅 앱

<br />

**목차** <br />
- [프로젝트 소개](#프로젝트-소개)
- [프로젝트 아키텍처 및 스택](#프로젝트-아키텍처-및-스택)
- [프로젝트에서 고민한 것들](#프로젝트에서-고민한-것들)
- [프로젝트 구현 화면 및 기능](#프로젝트-구현-화면-및-기능)

<br />

## 프로젝트 소개

- 개발 인원  :  강한결 (1인 프로젝트)
- 기간  :  2024.10.26 - 11.16 (3주)
- 최소 지원버전  :  iOS 17.0
- 주요 기능
    - 프리워커스 코인으로 라운지를 만들고 다른 사람을 초대하여 나만의 채팅 커뮤니티를 만들 수 있습니다.
    - 라운지에 다양한 주제의 채널을 만들어 여러 멤버들과 실시간 채팅을 주고 받을 수 있습니다.
    - 라운지에 속한 특정 멤버와 DM 채팅을 주고 받을 수 있습니다.

<br />

## 프로젝트 아키텍처 및 스택

| 스택 | 활용 |
|:-:|:-:|
| **MVVM** | 앱 구조 설계 |
| **Tuist** | 프로젝트 설정 및 모듈 분리 |
| **SwiftUI, Combine** | 컴포넌트 및 레이아웃 구현, 앱 상태 업데이트를 위한 데이터 흐름 관리|
| **URLSession, 소켓IO** | HTTP, 소켓 네트워크 비동기 통신 |
| **Swift Concurrency** | 비동기 태스크 동시성 관리 및 토큰/이미지 캐시 등의 공유 자원 스레드 접근 관리 |
| **SwiftData** | 채팅 데이터 관리 |
| **FileManager, NSCache** | 앱 전체 이미지 캐싱 관리 |
| **Confluence, Figma** | 프로젝트 기획 명세 및 앱 UI, User-Flow 설계 |
<br />

**DIContainer 기반 MVVM 패턴**

![freeworkers-architecture4@](https://github.com/user-attachments/assets/a765957b-9ada-4fbb-9aee-53f95bb1e23c)

> [DIContainer](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/App/Sources/Dependencies/DIContainer.swift)를 EnvironmentObject로 설정하여 앱 전역의 ViewModel, View에 필요한 서비스 객체를 주입했습니다.
>   - DIContainer에 각각의 Service 구현체를 직접 주입하지 않고, ViewModel에서 사용할 Usecase 단위로 ServiceType 프로토콜을 분리하여 모든 서비스 객체의 의존성을 가지는 통합 Service 객체를 주입하였습니다.
>   - Service 객체도 RepositoryType 프로토콜을 타입으로 주입하여 프로토콜에 명세한 기능을 활용했습니다.
>   - ViewModel은 필요한 데이터를 DIContainer의 Service가 제공해주는 기능으로 처리하여 뷰에 필요한 상태로 업데이트 했습니다.
> - ViewModelType 프로토콜을 적용하여 View의 Action(이벤트) 케이스별로 필요한 로직을 처리하는 형태의 ViewModel 구조를 설계했습니다.
<br />

**Tuist**
> App 모듈이 Framework 타겟으로 만들어진 NetworkService, DatabaseService, ImageProvider 모듈에 의존성을 가지는 형태로 프로젝트를 구성했습니다.
> - 네트워크 통신, 데이터베이스 모델링 및 관리 로직 구현, 이미지 캐싱 로직을 각 모듈이 구현하고, App 타겟에서 프레임워크 구현부를 신경쓰지 않고 기능을 이용하도록 역할을 분리시켰습니다.
<br />

**SwiftUI, Combine**
> SwiftUI로 반복 활용되는 재사용 컴포넌트를 만들고, 채팅 뷰에 필요한 레이아웃을 구현했습니다.
> - 채팅 UI와 채팅 중 공유된 이미지 파일을 모아보는 이미지 뷰어를 구현했습니다.
> - ScenePhase 환경 변수와 View 생명주기 메서드로 채팅 뷰가 화면에 사라지는 시점을 고려해 소켓 연결을 제어했습니다.
> 
> UseCase별 서비스 로직 처리 결과(성공, 에러 케이스)를 Combine Future Publisher로 핸들링 했습니다.
<br />

**URLSession, 소켓IO, Swift Concurrency**
> Network 모듈에 URLSession Async DataTask를 활용하는 HTTP 통신 서비스 객체를 구현했습니다.
> - EndpointProtocol을 구현하여 엔드포인트마다 서로다른 URLRequest가 반환되도록 설정했습니다.
> - 동일 모듈에 소켓 연결, 해제, 데이터 통신 기능을 반영한 소켓Service 객체를 구현했습니다.
>   - 소켓IO의 on 메서드로 소켓 채널을 활성화하고, 상대방이 보낸 채팅을 실시간으로 받아오는 이벤트를 처리했습니다. 소켓Service도 EndpointProtocol 기반에서 채널/DM 채팅을 구분시켰습니다.
> - Async-Await, Task 블록으로 모든 비동기 태스크의 동시성을 관리하고, AccessToken/ImageChache/소켓Client와 같이 여러 스레드에서 동시 접근이 가능한 공유 자원을 스레드 세이프하게 활용하기 위해 Actor를 활용했습니다.
<br />

**SwiftData**
> Database 모듈에 SwiftData 기반으로 채팅 데이터 모델을 구성하고 저장/조회/필터링 기능을 구현했습니다.
<br />

**Filemanager, NSCache**
> 서버 통신으로 받아온 이미지 데이터를 메모리, 디스크 캐시로 관리하는 ImageProvider 객체를 구현했습니다.
> - 채팅 뷰의 스크롤 이벤트나 탭 전환등으로 여러 이미지를 보여줘야 하는 경우마다 불필요한 네트워크 통신 자원을 사용하지 않기 위해 이미지 캐싱을 구현했습니다.
> - 다른 채팅 서비스 사용 경험을 기반으로 메모리 캐시는 최대 10분, 디스크 캐시는 최대 60일의 캐싱 전략을 반영했습니다.

<br />

## 프로젝트에서 고민한 것들

### 1. Tuist를 이용한 ImageKit, NetworkKit, DatabaseKit 역할 분리

> **1️⃣ 고민한 부분**

해당 프로젝트에서는,
- View를 그리고 View를 업데이트하는 상태를 관리하는 역할을 하는 App과
- 데이터를 서버에서 불러오고 데이터베이스 저장하는 등의 역할을 하는 Service 객체 구현을 분리시키고 싶었습니다.
- App 모듈에서는 서비스 구현체를 불러와 내부 구현 방식을 신경쓰지 않고 명세된 기능만 활용하여 앱을 동작시키는 로직을 처리하길 원했습니다.
- 구분된 서비스 모듈에서는 App 모듈이 어떻게 구현될지에 상관하지 않고, 각자의 역할을 수행할 수 있는 기능 구현만 신경쓰도록 구분짓고 싶었습니다.
<br />

> **2️⃣ 고민을 풀어간 방식 1 - 모듈 구분**

- **역할별 모듈을 구분하고 모듈간 의존성, 필요한 외부 모듈 주입을 위해 Tuist를 이용**했습니다. Tuist CLI로 프로젝트 설정 파일을 구성하고, 각 모듈의 Project 파일에서 Swift 객체로 모듈별 설정을 편하게 조정할 수 있었습니다.
- 역할에 따라 크게 **View와 View에 필요한 상태를 관리하는 ViewModel의 로직을 담고 있는 App Target**과 **데이터를 불러오고 저장하고 필요한 형태로 가공하는 Framework Target**으로 구분지었습니다.
- Framework Target은 다시 역할별로 아래와 같이 모듈을 나누었습니다.
  - HTTP/소켓 네트워크 통신을 담당하는 NetworkService Framework
  - 채팅 내역을 모델링하고 채팅 데이터를 저장/조회/필터링하는 Database Framework
  - 서버에서 받아온 이미지를 메모리/디스크 캐시로 관리하는 ImageCache Framework
  <br />
  <img width="500" src="https://github.com/user-attachments/assets/68781206-89eb-4635-b2f7-1ecd0e65fd6d" />

<br />

> **2️⃣ 고민을 풀어간 방식 2 - Framework 구현과 모듈 의존성 설정**

Network Framework는 HTTP/소켓 기반 네트워크 통신을 위해 아래 기능을 구현했습니다.
- 서버 엔드포인트별로 각각의 URLRequest를 맵핑해주는 [EndpointProtocol](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Network/Sources/Protocols/EndpointProtocol.swift)
- Endpoint 객체를 이용해 서버와 HTTP 통신을 하고 응답을 반환하는 [async request 함수](https://github.com/hankyeol-dev/freeworkers/blob/1262bc0a75832af7ab02b0f9f9ddb1a344534608/Freeworkers/Network/Sources/NetworkService.swift#L8)
- 에러 응답을 특정 코드로 반환해주는 Error 객체
- 소켓 통신을 위한 EndpointProtocol을 구분짓고, 소켓IO API를 활용해 [소켓 연결/종료/수신 이벤트를 처리하는 객체](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Network/Sources/소켓Service.swift)를 구현했습니다.
<br />

Database Framework는 SwiftData 프레임워크를 기반으로
- 채팅 데이터 저장을 위한 Database Model을 설정하고
- Database Model Container에 접근하여 데이터 저장/조회/필터링 하는 Model Context를 다루는 기능을 구현했습니다.
<br />

ImageCache Framework는 FileManager, NSCache를 다루고 두 객체로 이미지 캐싱을 처리하는 기능을 구현했습니다.
- 특정 만료 시점까지 메모리상의 캐시를 이용해 이미지 데이터를 저장하고 조회하는 MemoryCacheProvider
- 특정 만료 시점까지 샌드박스의 캐시 디스크 저장소를 이용해 데이터를 저장하고 조회하는 FilemanagerProvider
- Memory, Filemanager Cache를 이용하여 서버에서 받아온 이미지를 데이터로 변환해 저장하고, 앱에서 이미지가 필요할 때 불필요한 네트워킹 없이 이미지로 변환하는 기능이 구현된 ImageProvider
<br />

App 모듈이 세 개의 Framework 모듈에 의존성을 가지게 설정했습니다. App의 각 Repository에서 View 업데이트에 필요한 데이터 처리를 위해 Framework 모듈을 불러와 내부에 정의된 기능을 활용하는 방식으로 역할을 나누었습니다.

- 역할별로 모듈을 분리하고, 필요한 곳에서 모듈의 구현 방식은 신경쓰지 않고, 모듈이 제공하는 기능을 이용해 App 모듈만의 로직을 구현할 수 있었습니다.
<br />

> **3️⃣ 고민 과정에서 아쉬웠던 점**

App 모듈이 세 개의 Framework에 의존성을 가지고 있기 때문에, Framework 구현 범위를 넘어선 로직 설계가 필요할 수 있다는 생각이 들었습니다.
역으로 App 모듈에 필요한 기능을 반영하기 위해 Framework 모듈에 추가 작업이 필요하고, 유지 보수 측면에서 의도하지 않은 번거로움이 생길 수 있을 것 같았습니다. <br />

마찬가지로, App 모듈이 세 개의 Framework 구현체에 의존성을 가지는 부분도 아쉬웠습니다. DIContainer처럼 Framework 기능을 추상화한 프로토콜 타입을 통합적으로 가지는 상위 모듈이 있었다면 좋았을 것 같다는 생각을 했습니다. <br />

다음 프로젝트에서는, App Target의 UI Component, Feature, Test 단위로도 모듈을 구분하면서, 프로젝트 설계 단계부터 모듈간 의존성을 고려해보려고 합니다.

<br />

### 2. 소켓, 로컬 데이터베이스를 이용한 실시간 채팅 구현

> **1️⃣ 고민한 부분**

프로젝트의 핵심 서비스는 채널/유저간 실시간 채팅입니다. 실시간 채팅을 위해 서버에 소켓 통신이 준비되어 있었고, 앱 단에서 소켓을 통한 연결/차단/송·수신 이벤트를 핸들링해야 했습니다.

- 어떤 시점에 소켓을 연결하고 끊어야 하는지부터 채팅 데이터를 전송하고 다른 유저가 보낸 내역을 수신하는 체계를 고민했습니다.
- 이전 채팅 내역은 어떤 방식으로 관리할 것인지도 함께 고민했습니다.
- 채팅 뷰에서는 텍스트/이미지 채팅 데이터를 어떤 레이아웃으로 보여줄 것인지를 고려했습니다.
<br />

> **2️⃣ 고민을 풀어간 방식 1 - 소켓Service와 연결 시점 관리**

소켓 통신을 담당하는 [SocketService 객체](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Network/Sources/소켓Service.swift)를 Network Framework 모듈에 구현했습니다. 
- 소켓IO의 `SocketIOClient` 인스턴스로 통신 연결/차단을 제어하고,
- `.on` 메서드로 특정 채팅 방의 채팅 데이터 수신 이벤트를 연결하는 기능을 구현했습니다.
- NetworkService와 마찬가지로, 소켓 통신을 위한 EndpointProtocol을 만들어 App에서 구조화된 요청 객체를 전달하게 만들었습니다.
<br />

App에서는 유저가 **채팅 방(채널, DM)에 입장하는 시점에 이전 채팅 내역 존재 여부를 파악한 다음 소켓을 연결**하였습니다.
- 입장한 방에 이전 채팅 내역이 있거나, 서버에서 추가로 받아와야 하는 읽지 않은 채팅 내역이 있을 경우 **소켓 연결 전에 채팅 데이터 싱크를 먼저 맞추었습니다.** 조회한 데이터를 로컬 데이터베이스에 순서대로 **저장한 다음 `.connect` 함수를 호출해 소켓을 연결**했습니다.
- 이전 채팅 내역이 없는 새롭게 생성된 채널, DM인 경우에는 **유저가 최초 채팅 데이터를 전송하는 시점에 소켓을 연결**했습니다.
<br />

소켓 **연결 해제는 유저가 채팅 방을 어떤 형태로 이탈하였는지에 따라 구분**하였습니다.
- 기본적으로, pop 이벤트가 반영된 뒤로가기 버튼을 터치하여 **채팅 View가 사라지는 시점에 연결을 해제**했습니다. 또한 ScenePhase 환경 변수로 앱이 **background inActive 상태가 된 경우를 감지해 소켓 연결을 해제**했습니다.
- 채팅 중, 이미지 파일 첨부를 위해 화면이 fullCover 되거나, 이미지 뷰어가 overlap 되는 경우는 **채팅 View가 가리더라도 채팅 방을 이탈한 경우가 아니기 때문에 연결을 해제하지 않았습니다.**
<br />

> **2️⃣ 고민을 풀어간 방식 2 - 채팅 데이터 송·수신 및 내역 저장**

유저가 채팅 방에 입장하면 가장 먼저 해당 채팅 방의 이전 채팅 내역을 조회했습니다.
- 채팅 방에 입장할 때마다 이전 채팅 내역을 서버에 요청하면 네트워크 리소스가 과하게 소모된다고 판단했습니다. 그래서, 로컬 데이터베이스에 채팅 모델을 정의하여 채팅 방별로 이전 내역을 저장하였습니다.
- 데이터베이스에 가장 마지막으로 저장된 채팅 데이터의 `createdAt` 값으로 서버에 추가로 전송된 채팅 내역을 조회했습니다. 추가된 채팅 내역이 서버에 있다면 해당 데이터를 로컬 데이터베이스에 추가로 저장하여 서버와 싱크를 맞추었습니다.
<br />

유저의 채팅 전송은 HTTP 요청으로 처리하였습니다.
- 채팅 데이터(body)가 정상적인 요청 객체로 들어왔는지, 서버에 정상적으로 저장되었는지 등을 고려하여 성공 응답을 받았을 경우에만 소켓 채널을 통해 채팅 데이터가 전달되었습니다. 
- 서버 성공 응답을 받은 경우에만 로컬 데이터베이스에 전송 데이터를 저장하였습니다. 실패 응답을 받았을 때는 Error Toast를 띄우고 TextView, ImageSelector의 상태를 따로 변경하지 않았습니다.
<details>
  <summary>채팅 전송 코드</summary>

##### SendDM 코드  
```swift
 private func sendDM() async {
   ...
   // 채팅 전송 객체
   let input : ChatInputType = .init(
        loungeId: loungeId,
        roomId: roomId,
        chatInput: .init(content: .init(content: chatText), files: photoDatas.map({ $0.1 })))
           
    // 채팅 전송 요청
    await diContainer.services.dmService.sendDM(input: input)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] errors in
            // 채팅 전송에 실패한 경우 -> Toast View Display
            if case let .failure(error) = errors {
                self?.toastConfig = .error(message: error.errorMessage, duration: 1.0)
            }
        } receiveValue: { chat in
            // 채팅 전송에 성공한 경우 -> 채팅 바, 채팅 이미지 리셋 및 데이터 저장
            Task { [weak self] in
                self?.validateResetView()
                await self?.saveMyChat(chat.toSaveRequest)
            }
        }
        .store(in: &store)
 }
```
</details>
<br />

`.receive` 메서드로 소켓을 통해 채팅 데이터를 수신하였습니다.
- 유저 자신이 전송한 채팅 데이터도 소켓을 통해 전달받기 때문에, 전송 요청이 성공한 시점에 데이터베이스에 채팅 레코드가 쌓였다면 소켓을 통해 전달받는 동일 데이터는 저장하지 않도록 처리했습니다.
- 다른 유저가 전송한 채팅은 바로 데이터베이스에 저장하고 View가 업데이트 될 수 있도록 처리했습니다.

<details>
  <summary>수신한 채팅 데이터 저장 코드</summary>

##### ReceivedChat  
```swift
 // 내가 보낸 채팅을 저장하는 로직
 private func saveMyChat(_ chat : ChatSaveRequestType) async {
    if validateIsNotSaved(chat.chatId) { // 전송 시점에 이미 저장되지 않았다면 저장
        let saved = await diContainer.services.dmService.saveDM(loungeId: loungeId,
                                                                 chatRequest: chat)
        chats.append(saved)
        validateResetView()
    }
 }
       
 // 소켓으로 수신한 채팅 내역이 로컬 데이터베이스 잘 저장되었다면 View 업데이트
 private func saveReceivedChat(_ chat : ChatSaveRequestType) async {
    if let saved = await diContainer.services.dmService.saveReceivedDM(loungeId: loungeId, chatRequest: chat) {
        chats.append(saved)
        validateResetView()
    }
 }
```
</details>
<br />

> **2️⃣ 고민을 풀어간 방식 3 - 채팅 UI, 레이아웃 구성**

채팅 데이터 전송을 위해 텍스트를 입력하고 이미지 파일을 선택할 수 있는 채팅 바를 구현했습니다.
- 채팅 텍스트를 입력하는 TextView는 UITextView를 확장해서 UIViewRepresentable View로 구현했습니다. TextView의 최대 높이를 지정하고, `updateUIView` 메서드 내부에서 유저의 텍스트 입력에 따라 높이가 최대치까지 늘어나도록 설정했습니다. UITextViewDelegate를 채택해 placeholder를 함께 반영했습니다.
- TextView 상단에는 유저가 PhotosPicker로 선택한 이미지 목록을 볼 수 있는 ThumbnailView를 반영했습니다. PhotosUI의 loadTransferable 메서드로 선택된 이미지를 Data 타입으로 추출하여 채팅 전송에 활용했습니다.
<details>
  <summary>채팅 바 UI</summary>

##### ChatBar  
<img width="330" src="https://github.com/user-attachments/assets/f07341a8-84cd-4425-8e68-9113e90c1dac" />
</details>
<br />

채팅 뷰에서는 내가 보낸 채팅, 다른 유저가 보낸 채팅을 구분하였고, 채팅 텍스트 길이를 계산한 컴포넌트를 구현했습니다.
- 내가 보낸 채팅은 유저 프로필 UI를 제외하고 Trailing에 정렬되도록 설정했습니다. 다른 유저가 보낸 채팅은 유저 프로필을 보여주고, Leading으로 정렬시켰습니다.
- `GeometryProxy` 속성을 이용하여 채팅 텍스트가 특정 width를 초과하는지 연산하여 한 번에 최대 3줄까지 보여지는 채팅 뷰를 구현했습니다. 유저는 '전체 확인하기' 버튼을 통해 채팅 텍스트 전문을 확인할 수 있게 컴포넌트를 구성했습니다.
<details>
  <summary>채팅 뷰 - 메시지 UI</summary>

##### ChatView - Text
<img width="330" src="https://github.com/user-attachments/assets/bbb7c978-ee1a-47d2-ab2a-4e189e957e4d" /> <img width="330" src="https://github.com/user-attachments/assets/155d8cca-bbec-48c1-8bd7-24e619b8c5e6" /> 
</details>
<br />

이미지 데이터는 LazyHGrid를 이용해 그리드 형태로 최대 3장의 이미지를 보여주었습니다.
- 최대 5개의 이미지 데이터를 송·수신할 수 있었기 때문에, 추가 이미지는 갯수를 노출시켰습니다. 그리드의 이미지를 터치하면 이미지 뷰어를 띄워 이미지를 정사이즈로 확인할 수 있게 구현했습니다.
<details>
  <summary>채팅 뷰 - 이미지 UI</summary>

##### ChatView - Image
<img width="330" src="https://github.com/user-attachments/assets/c1aba2ac-9685-4dc7-8124-846b2e91d51a" /> <br />
<img width="330" src="https://github.com/user-attachments/assets/bc2b64fb-1477-427e-9188-b8b117943408" /> 
</details>
<br />

> **3️⃣ 고민 과정에서 아쉬웠던 점**

채팅 서비스를 구현하면서 발생할 수 있는 엣지 케이스가 너무 많다는 것을 확인했습니다. 네트워크 연결이 힘든 곳에서 채팅을 전송할 경우 전송 실패 내역을 어떻게 보여줄 것인지, 특정 채팅에 대한 답장은 어떻게 처리할 수 있는지 등을 많이 고려해보게 되었습니다. 한 번에 완성형 채팅 서비스를 구현하기 보다는 유저 시나리오를 설계해보면서 서비스에 우선적으로 필요한 서비스 로직과 뷰를 업데이트 해보고자 합니다.

<br />

### 3. FileManager Cache Directory, NSCache를 활용한 이미지 캐싱 적용

> **1️⃣ 고민한 부분**

앱에서 서버에 저장한 이미지를 불러와 보여주는 경우가 많았습니다. (채팅 View의 이미지 그리드, 라운지 설정 View의 유저 프로필 목록 등)
- 이미지 랜더링이 필요할 때마다 네트워크 요청으로 데이터를 가져오면 불필요한 자원 소모가 발생했습니다.
- 특히, 채팅 View에서 스크롤에 따라 ChatView를 재사용 하는 경우 별다른 제약이 없다면 계속 네트워크 요청이 들어가 메모리 사용이 급격하게 증가하는 것을 경험했습니다. (스크롤을 할 때마다 메모리 사용량이 우상향)

<img width="450" alt="385157148-7618a923-4a45-4b1d-89ac-14c18657ec28" src="https://github.com/user-attachments/assets/d71fdf47-34e6-45f2-882d-3f8213a5b6a7">
<br />

> **2️⃣ 고민을 풀어간 방식**

이미지 캐싱을 처리하는 Framework 모듈을 구현하여, 이미지가 필요할 때 메모리/디스크 상의 메모리 저장소를 먼저 확인하도록 만들었습니다.
- [ImageObject](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Image/Sources/Internal/ImageObject.swift)라는 커스텀 참조 타입을 만들어 이미지 데이터와 보관 완료 시점을 함께 반영하였습니다.
<br />

NSCache 인스턴스를 기반으로 ImageObject를 관리하는 [MemoryCacheProvider](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Image/Sources/Public/MemoryCacheProvider.swift) Actor 서비스 객체를 만들었습니다. 
- 이미지 요청에서 동일 이미지를 조회할 때 Tread-safe를 보장시키기 위해 Actor로 구현했습니다.
- 서버에서 보내주는 정적 Image PathString과 ImageObject를 키-밸류 조합으로 NSCache 인스턴스에 저장하고, 이후 PathString으로 저장한 ImageObject를 조회하는 로직을 구현했습니다.
- 메모리 캐싱 전략은 ImageObject당 10분의 보관 만료 시점을 가지도록 산정했습니다. MemoryCacheProvider 객체 생성자에서 타이머를 통해 5분 단위로 메모리상에서 만료된 ImageObject를 지우도록 설정했습니다. 채팅이 필요할 때 앱에 들어와 짧은 시간 메모리를 활용할 수 있도록 10분을 산정했습니다.
  ```swift
   private func removeEstimatedExpire() { // 메모리에서 만료된 ImageObject를 찾아 삭제하는 로직
      for key in cacheKeys {
         guard let imageObject = cache.object(forKey: key) else {
            cacheKeys.remove(key)
            return
         }
         
         if imageObject.isExpired {
            cache.removeObject(forKey: key)
            cacheKeys.remove(key)
         }
      }
   }
  ```
<br />

디스크 캐시는 FileManager의 Cache 전용 디렉토리를 만들어 이미지가 특정 기간동안 저장되도록 구현했습니다.
- 디스크 캐싱 처리 역시 동시 상태에서 Tread-safe를 보장하기 위해 Actor 기반의 [FilemanagerProvider](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Image/Sources/Public/FilemanagerProvider.swift) 서비스 객체로 구현했습니다.
- 메모리 캐싱과 동일하게 서버에서 보내준 Image PathString을 디렉토리 접근 URL로 만들어 ImageObject의 이미지 데이터를 저장하였습니다.
- 다른 채팅 서비스에서 이미지 파일을 최대 30~60일 정도 보관한다는 점을 확인하여, 최대 60일까지 보관하는 캐싱 전략을 채택했습니다. FileManager의 `.modificationDate` 속성을 이용해서 저장한 이미지 데이터의 만료 시점을 계산하고 데이터를 지울 수 있었습니다.
  ```swift
   public func removeAllExpired() {
     ... 
     let expiredList = urls.filter { url in
        do {
          let attribute = try fileManager.attributesOfItem(atPath: url.path())
          if let expired = attribute[.modificationDate] as? Date { // 특정 url의 이미지 파일 만료 시점이 초과되었는지 확인
             return expired.timeIntervalSince(Date()) <= 0
          }
        } catch {
          return false
        }

        return false
      }
   
     for expiredURL in expiredList {
       try? fileManager.removeItem(at: expiredURL)
     }
   }
  ```
<br />

최종적인 이미지 캐싱은 ImagePathString을 이용해 메모리 캐시 -> 디스크 캐시 순서로 데이터를 확인하고, 일치하는 데이터를 찾지 못할 경우 서버에 이미지 파일을 요청하는 과정으로 진행했습니다. ([ImageProvider](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Image/Sources/ImageProvider.swift))
- 서버 요청으로 받아온 이미지 데이터는 메모리, 디스크 캐시 저장소에 저장하여 만료 시점까지 활용했습니다.
- 메모리 캐시의 만료로 디스크에만 있는 이미지는 다시 메모리 캐시에 임시 저장하여 더 빠르게 데이터 접근이 가능하도록 처리했습니다.
![freeworkers-imagecache](https://github.com/user-attachments/assets/5c5fd4d2-f620-443f-acb5-a227d47fed7a)
<br />

이미지 캐시 구현으로 스크롤과 같은 View 이벤트에 따라 메모리 사용이 급격하게 늘어나는 문제를 크게 해소할 수 있었습니다.
- 위와 같은 채팅방에서 동일한 스크롤 이벤트를 했을 때, 최소 8배 적게 메모리 사용을 줄일 수 있었습니다.
<img width="450" alt="385157169-117334ce-b693-475c-b842-905dbd6a36aa" src="https://github.com/user-attachments/assets/ef18e46e-bfa4-466e-8911-3834cb44daa2">
<br />

3️⃣ 고민 과정에서 아쉬웠던 점

HTTP 응답 헤더의 ETag 속성을 이용해 서버 자원과 캐싱하는 자원의 동일성을 검증하는 방식을 알고 있습니다. 이번 프로젝트에서 활용한 서버는 ETag 방식을 지원하지 않고, 이미지가 업데이트 될 때마다 변경된 정적 Image Path를 제공해주었습니다. ETag 자체를 캐시 키로 활용하여 동일한 값이 없는 경우만 네트워킹을 하는 방식으로도 캐싱을 구현해볼 수 있을 것 같습니다.

<br />

## 프로젝트 구현 화면 및 기능

| 1. 로그인 화면 | 2. 라운지 생성/편집 | 3. 라운지 목록 | 4. 사이드 라운지 목록 |
|:--:|:--:|:--:|:--:|
|<img width="200" src="https://github.com/user-attachments/assets/5b91c1f0-fd1d-4fa4-b43f-6f18cfd0d686" /> |<img width="200" src="https://github.com/user-attachments/assets/2b723a5a-12f1-4398-87db-bcfa371bb078"/> |<img width="200" src="https://github.com/user-attachments/assets/fd55e036-cab2-4546-8974-89737bbab422" />|<img width="200" src="https://github.com/user-attachments/assets/3dad9b80-1050-42d2-a79b-a4ba9b6dbe61" /> |

- 로그인 화면에서는 개인 이메일 또는 애플 계정을 이용해 로그인 할 수 있습니다.
  - 프로젝트에 `Sign In With Apple` Capability를 추가하여 Apple OAuth Credential을 확인하고, 서버에 디바이스 토큰 Id와 함께 로그인 정보를 전달하여 유저 인증을 진행했습니다.
- 가입시 지급되는 프리워커스 코인을 이용해 나만의 라운지를 생성할 수 있습니다. 라운지 관리자일 경우 설정 화면에서 라운지 정보를 수정할 수 있습니다.
- 유저가 생성/초대된 라운지 목록은 전체 화면, 사이드 목록 화면으로 확인할 수 있습니다.

<br />

| 5. 라운지 메인 화면 | 6. 라운지 DM 목록 | 7. 라운지 설정 화면 | 8. 라운지 관리자 변경 |
|:--:|:--:|:--:|:--:|
|<img width="200" src="https://github.com/user-attachments/assets/c4e6bf5a-5e13-4a53-8ec5-20a6ccdbba64" />|<img width="200" src="https://github.com/user-attachments/assets/fd359085-2eda-43c0-abfa-d2ec34c0de61" />|<img width="200" src="https://github.com/user-attachments/assets/8a6c1d77-9c32-4e62-ad83-7b86ca8c01b8" />|<img width="200" src="https://github.com/user-attachments/assets/399ea599-6414-4d74-9ac9-bffd8cf2a65b" />|

- 라운지 메인 화면에서는 유저가 현재 참여한 채널 목록, 채팅을 나눈 적 있는 DM 목록을 조회할 수 있습니다.
  - 마지막으로 확인한 채팅 이후에 추가 채팅이 온 채널 또는 DM은 몇 개의 채팅이 쌓여있는지 확인할 수 있습니다. 채널/DM 목록을 조회하는 로직에서 각각의 마지막 채팅 데이터를 찾고, 해당 데이터를 기반으로 서버에 Unreads 갯수를 확인하는 요청을 보내 TaskGroup으로 한 번에 확인할 수 있도록 구현했습니다. ([코드](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/App/Sources/Services/DMService.swift#L86))
- 라운지에서 DM을 보낸 목록을 따로 확인할 수 있고, 라운지에 있는 멤버 목록을 조회하여 DM을 보낼 수 있습니다.
- 라운지 관리자의 경우, 라운지 설정에서 라운지 설정/관리자/삭제를 진행할 수 있습니다. 라운지 참여 멤버는 라운지를 나갈 수 있습니다.

<br />

| 9. 채팅 뷰 | 10. 채팅 바 | 11. 채팅 이미지 뷰어 | 12. 채팅 전체 내역 확인 |
|:--:|:--:|:--:|:--:|
|<img width="200" src="https://github.com/user-attachments/assets/f7e5d601-0a8c-4087-8a25-ade7448404ff" />|<img width="200" src="https://github.com/user-attachments/assets/53b21308-8477-4892-8273-612f5044e3ea" />|<img width="200" src="https://github.com/user-attachments/assets/2650273d-9415-472a-823c-c97a8e2cd9c6" />|<img width="200" src="https://github.com/user-attachments/assets/2bbd66c9-127a-4271-8b87-2c379cc0dcee" />|

- 채팅 뷰에서는 채팅 텍스트, 이미지 목록을 확인할 수 있습니다. 내가 보낸 채팅과 다른 유저가 보낸 채팅의 레이아웃을 구분지어 확인할 수 있습니다. ([ChatView](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/App/Sources/Views/Reusable/FWChat.swift))
- 채팅 텍스트 바는 특정 높이 이상으로 늘어나지 않으며, 최대 높이에 도달할 경우 내부에 스크롤이 생겨 긴 내용의 채팅을 보낼 수 있습니다. ([ChattingBarTextView](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/App/Sources/Views/Reusable/FWChatTextView.swift))
  - 채팅 텍스트는 최대 3줄까지 노출되고, 그 이상일 경우 '전체 확인하기' 버튼으로 뷰를 늘려 내용을 확인할 수 있습니다.
- 최대 5장의 이미지를 채팅으로 전송할 수 있습니다. 전송/수신된 이미지 목록은 이미지 뷰어를 통해 크게 확인할 수 있습니다. ([ChatImageViewer](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/App/Sources/Views/Reusable/FWImageViewer.swift))

<br />

| 13. 내 프로필 | 14. 다른 유저 프로필 | 15. DM 뷰 |
|:--:|:--:|:--:|
|<img width="200" src="https://github.com/user-attachments/assets/59b4dfbc-242e-41f1-86c5-da13b94ee258" />|<img width="200" src="https://github.com/user-attachments/assets/d480e9f3-0628-40f3-955b-e1535ef2d880" />|<img width="200" src="https://github.com/user-attachments/assets/6c4f6c29-15e4-4b3c-83f3-0c8580a424bf" />|

- 유저 프로필을 조회할 수 있습니다.
  - 내 프로필에서는 프로필 정보를 편집할 수 있고 (이미지, 닉네임, 전화번호), 라운지 생성을 위한 프리워커스 코인을 실 결제로 충전할 수 있습니다.
  - 다른 유저 프로필에서는 유저 정보를 확인하고, DM 보내기 버튼으로 DM 채팅을 보낼 수 있습니다.
- DM 방에서는 채널 채팅과 동일하게 텍스트, 이미지 채팅을 보낼 수 있습니다. 채널 채팅과는 다르게 유저간 1:1 채팅을 지원합니다.

<br />
