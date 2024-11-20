# Freeworkers

‘일(Work)’상에서 벗어나 나만의 라운지를 만들고, 함께하는 사람을 초대해 즐겁게 소통하는 채팅 앱

<br />

**목차** <br />
> - [프로젝트 소개](#-프로젝트-소개)
> - [프로젝트 아키텍처 및 스팩](#-프로젝트-아키텍처-및-스팩)
> - [프로젝트에서 고민한 것들](#-프로젝트에서-고민한-것들)
> - [프로젝트 구현 화면 및 기능](#프로젝트-구현-화면-및-기능)

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
| **URLSession, SocketIO** | HTTP, Socket 네트워크 비동기 통신 |
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
> - ScenePhase 환경 변수와 View 생명주기 메서드로 채팅 뷰가 화면에 사라지는 시점을 고려해 Socket 연결을 제어했습니다.
> 
> UseCase별 서비스 로직 처리 결과(성공, 에러 케이스)를 Combine Future Publisher로 핸들링 했습니다.
<br />

**URLSession, SocketIO, Swift Concurrency**
> Network 모듈에 URLSession Async DataTask를 활용하는 HTTP 통신 서비스 객체를 구현했습니다.
> - EndpointProtocol을 구현하여 엔드포인트마다 서로다른 URLRequest가 반환되도록 설정했습니다.
> - 동일 모듈에 Socket 연결, 해제, 데이터 통신 기능을 반영한 SocketService 객체를 구현했습니다.
>   - SocketIO의 on 메서드로 Socket 채널을 활성화하고, 상대방이 보낸 채팅을 실시간으로 받아오는 이벤트를 처리했습니다. SocketService도 EndpointProtocol 기반에서 채널/DM 채팅을 구분시켰습니다.
> - Async-Await, Task 블록으로 모든 비동기 태스크의 동시성을 관리하고, AccessToken/ImageChache/SocketClient와 같이 여러 스레드에서 동시 접근이 가능한 공유 자원을 스레드 세이프하게 활용하기 위해 Actor를 활용했습니다.
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

1️⃣ 고민한 부분

해당 프로젝트에서는,
- View를 그리고 View를 업데이트하는 상태를 관리하는 역할을 하는 App과
- 데이터를 서버에서 불러오고 데이터베이스 저장하는 등의 역할을 하는 Service 객체 구현을 분리시키고 싶었습니다.
<br />

- App 모듈에서는 서비스 구현체를 불러와 내부 구현 방식을 신경쓰지 않고 명세된 기능만 활용하여 앱을 동작시키는 로직을 처리하길 원했습니다.
- 구분된 서비스 모듈에서는 App 모듈이 어떻게 구현될지에 상관하지 않고, 각자의 역할을 수행할 수 있는 기능 구현만 신경쓰도록 구분짓고 싶었습니다.
<br />

2️⃣ 고민을 풀어간 방식 1 - 모듈 구분

- **역할별 모듈을 구분하고 모듈간 의존성, 필요한 외부 모듈 주입을 위해 Tuist를 이용**했습니다. Tuist CLI로 프로젝트 설정 파일을 구성하고, 각 모듈의 Project 파일에서 Swift 객체로 모듈별 설정을 편하게 조정할 수 있었습니다.
- 역할에 따라 크게 **View와 View에 필요한 상태를 관리하는 ViewModel의 로직을 담고 있는 App Target**과 **데이터를 불러오고 저장하고 필요한 형태로 가공하는 Framework Target**으로 구분지었습니다.
- Framework Target은 다시 역할별로 아래와 같이 모듈을 나누었습니다.
  - HTTP/Socket 네트워크 통신을 담당하는 NetworkService Framework
  - 채팅 내역을 모델링하고 채팅 데이터를 저장/조회/필터링하는 Database Framework
  - 서버에서 받아온 이미지를 메모리/디스크 캐시로 관리하는 ImageCache Framework
  <br />
  <img width="500" src="https://github.com/user-attachments/assets/68781206-89eb-4635-b2f7-1ecd0e65fd6d" />

<br />

2️⃣ 고민을 풀어간 방식 2 - Framework 구현과 모듈 의존성 설정

Network Framework는 HTTP/Socket 기반 네트워크 통신을 위해 아래 기능을 구현했습니다.
- 서버 엔드포인트별로 각각의 URLRequest를 맵핑해주는 [EndpointProtocol](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Network/Sources/Protocols/EndpointProtocol.swift)
- Endpoint 객체를 이용해 서버와 HTTP 통신을 하고 응답을 반환하는 [async request 함수](https://github.com/hankyeol-dev/freeworkers/blob/1262bc0a75832af7ab02b0f9f9ddb1a344534608/Freeworkers/Network/Sources/NetworkService.swift#L8)
- 에러 응답을 특정 코드로 반환해주는 Error 객체
- Socket 통신을 위한 EndpointProtocol을 구분짓고, SocketIO API를 활용해 [Socket 연결/종료/수신 이벤트를 처리하는 객체](https://github.com/hankyeol-dev/freeworkers/blob/main/Freeworkers/Network/Sources/SocketService.swift)를 구현했습니다.
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

3️⃣ 고민 과정에서 아쉬웠던 점

App 모듈이 세 개의 Framework에 의존성을 가지고 있기 때문에, Framework 구현 범위를 넘어선 로직 설계가 필요할 수 있다는 생각이 들었습니다.
역으로 App 모듈에 필요한 기능을 반영하기 위해 Framework 모듈에 추가 작업이 필요하고, 유지 보수 측면에서 의도하지 않은 번거로움이 생길 수 있을 것 같았습니다. <br />

마찬가지로, App 모듈이 세 개의 Framework 구현체에 의존성을 가지는 부분도 아쉬웠습니다. DIContainer처럼 Framework 기능을 추상화한 프로토콜 타입을 통합적으로 가지는 상위 모듈이 있었다면 좋았을 것 같다는 생각을 했습니다. <br />

다음 프로젝트에서는, App Target의 UI Component, Feature, Test 단위로도 모듈을 구분하면서, 프로젝트 설계 단계부터 모듈간 의존성을 고려해보려고 합니다.

<br />

### 2. Socket, 로컬 데이터베이스를 이용한 실시간 채팅 구현

1️⃣ 고민한 부분

- 실시간 채팅이 주 서비스였고, 서버에서 socket 통신을 할 준비가 되어 있었다. socket을 연결하고, 끊어주는 시점
- 소캣 통신 중에 받아온 데이터를 다음번 입장에서도 보여주기 위해서는?
- 채팅 뷰에서는 기존 채팅 서비스의 어떤 레이아웃을 효과적으로 보여줄 수 있는지?
<br />

2️⃣ 고민을 풀어간 방식

- socketIO의 on 메서드로 채널/DM 기반의 채팅 방 연결을 열고, 닫고, 메시지를 받는 서비스 객체 구현
  - 소캣을 닫는 시점 : 앱이 백그라운드에 전환된 경우, 뒤로 나가기를 통해 채팅방을 나간 경우 / 소캣을 닫지 않는 경우 : 같은 채널안에서 채널 설정을 컨트롤 하는 경우  
- 채팅 방식 (채널)
  - 채팅을 보내는 경우
    - 데이터베이스에 저장된 이전 채팅 데이터를 createdAt 기준으로 조회 -> createdAt을 통해 더 불러올 채팅 내역이 있는지 서버에 요청 -> 해당 데이터를 불러와 로컬에 저장 후 소캣 오픈
    - 채팅 전송 HTTP 요청을 보내고 성공 응답이 오면 로컬 데이터베이스에 저장
  - 채팅을 받는 경우, 소캣을 통해 전달받은 데이터를 데이터베이스에 저장
- 채팅 방식 (DM)
  - DM의 경우, 누구 하나가 먼저 챗을 보내지 않으면 방이 따로 만들어지지 않고, 데이터베이스 레코드도 형성되지 않음
  - 채팅 전송시에 이전 데이터가 있는지 검증하고, 처음이라면 DM 방을 만들고, 이후에 채널 방식과 동일하게 진행

 - 채팅 뷰를 구현하기 위해서
   - 특정 높이까지 늘어나는 TextView 커스텀 -> 채팅바로 활용
   - 채팅뷰에서는 내가보낸, 다른 유저가 보낸 채팅을 구분하여 레이아웃을 변경, 특정 길이 이상인 경우 접어서/펼쳐서 확인
   - 채팅을 통해 보내진 이미지 파일은 이미지 뷰어를 통해 큰 화면으로 확인할 수 있도록
<br />

3️⃣ 고민 과정에서 아쉬웠던 점

- 네트워크 연결이 힘든 곳으로 전환되었을 때를 고려하는 로직 / 뷰를 추가적으로 고려해보고자 한다.

<br />

### 3. FileManager Cache Directory, NSCache를 활용한 이미지 캐싱 적용

1️⃣ 고민한 부분

- 앱에서 서버에 저장한 이미지를 불러와 보여주는 경우가 많았음 (채팅 뷰 + 이미지 뷰어, 라운지 유저 목록, 라운지/DM 목록 등)
- 필요할 때마다 네트워크 요청이 들어가면 불필요한 자원 소모가 발생했음 (스크롤에 따라 메모리 사용이 크게 늘어나느 이미지)
<br />

2️⃣ 고민을 풀어간 방식

- 이미지 캐싱 방식 : NSCache를 이용한 Memory 캐싱을 기반으로 FileManager와 같은 디스크 저장소 활용
  - 네트워크 > 메모리 + 디스크 저장 > 다음에 불러올 때 메모리>디스크>네트워크 순서로 조회
- 이미지 캐싱 전략 : 메모리 캐싱의 경우 10분, 디스크 캐싱의 경우 60일
<br />

3️⃣ 고민 과정에서 아쉬웠던 점

- 서버에서 ETag를 통해서 서버 자원과 캐싱하는 자원의 동일성을 검증하는 경우가 있다고 함 > Etag가 동일한 경우만 불러오는 로직으로 처리해볼 수 있음
  - 서버에서 이미지가 업데이트 될 떄마다 새롭게 생성된 static url을 제공해주고 있었음 

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
