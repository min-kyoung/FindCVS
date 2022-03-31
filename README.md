# FindCVS
## Description
* Rx, MVVM 구조, 카카오의 OpenAPI인 Local API, 애플 CLLocationManager를 활용하여 내 근처 편의점을 나타내주는 프로젝트이다.
* 상단에는 카카오 맵을 띄우고 빨간색 핀으로 어디에 편의점에 위치해있는지 보여주며 하단에는 편의점의 목록을 보여준다.
* 맵과 리스트의 데이터는 Rx binding을 통해서 연결할 것이다. 따라서 핀을 선택하면 해당 편의점을 리스트에서도 보여주고, 리스트의 편의점을 선택해도 해당 편의점이 맵의 중심에 오도록 맵을 이동한다.
* 가까운 곳에 편의점이 없거나 에러가 발생하면 AlertController를 통해 어떠한 에러가 발생했는지 표시한다.
#### 구현화면
<img src="https://user-images.githubusercontent.com/62936197/160845313-292eb5a0-7606-4a59-873a-1189b06406e6.png" width="150" height="320"> 　<img src="https://user-images.githubusercontent.com/62936197/160845315-6227b693-93f6-4260-a3f4-5041ef8161f5.png" width="150" height="320"><br>

## Prerequisite
* XCode Version 13.2.1에서 개발을 진행하였다.
* Kakao API를 사용하기 위해 **https://developers.kakao.com** 에 로그인을 한다.
  * **내 애플리케이션**을 추가한다.
  * **문서 > 지도/로컬 API 가이드 > iOS > Guide**에서 SDK를 다운받는다.
    * 다운받은 SDK는 압축을 풀어 해당 프로젝트가 있는 폴더로 옮기고, XCode를 열어 Frameworks에 추가헤준다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227094-5c1f8d86-ebc4-4051-8251-2d0e96376fc2.png" width="450" height="170"> 
   
* Kakao Map API 연결 
  * 번들 ID와 일치하는 앱에서만 지도 API를 사용할 수 있도록 네이티브엡키를 info.plist에 추가한다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227110-2c7b7322-83d5-465c-a7b3-d9ede433966f.png" width="550" height="30"> 　
  * DaumMap framework를 사용하려면 이 외에도 다른 framework를 수동으로 처리해주어야 한다. 이 전에는 cocoapod이나 swift package 매니저를 설치하여 자동적으로 해결이 되었다면, 지도 SDK가 그러한 툴을 제공하지 않기 때문에 다른 framework를 수동으로 추가한다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227227-36e40ce9-9832-4598-8a45-e7894e8f03e4.png" width="550" height="170"> 　
  * Mac용 SDK는 ARC를 지원하지 않기 때문에 NO로 변경 후 저장한다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227230-ae02801d-bcbe-4e04-821f-595cd928b1c7.png" width="550" height="60"> 　
  * SDK는 Object-C로 되어있기 때문에 Swift에서 사용하기 위해 BridgingHeader를 추가한다.
  * 추가한 BridgingHeader를 XCode가 확인할 수 있도록 BridgingHeader의 path를 입력한다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227231-0c0fc194-0c89-4286-9731-a94d7a02c979.png" width="550" height="70"> 　
## Usage
#### 카카오의 OpenAPI인 Local API 
* 카카오의 지도 SDK를 기반으로 iOS, Android 등의 플랫폼 서비스에서 카카오 맵을 활용할 수 있도록 다양한 메서드와 라이브러리를 통한 커스텀 기능을 제공한다.
#### 애플의 CLLocationManager 
* 사용자의 위치는 개인적인 정보이므로 앱에서 위치관련 이벤트를 활용하기 위해서는 사용자의 허락이 필요하다. 
* CLLocationManager는 앱에 대한 위치 관련 이벤트 전달을 시작하거나 중지하는데 사용하는 객체이다. 
* 앱에 위치 서비스를 추가하려면 CLLocationManager를 사용해서 Delegate를 구현하고 앱에 필요한 위치 정보에 엑세스할 수 있는 권한을 부여할지 여부를 결정하면 된다.
* CLLocation과 같이 현재 위치를 사용하는 경우에는 시뮬레이터에서 정상적인 테스트가 어렵다. <br>
  시뮬레이터에서는 자신의 현재 위치를 제대로 받아올 수 없기 때문에 디버그 모드일 때와 그렇지 않을 때에 대해서 임의의 좌표값을 입력해주어야 한다.
## Files
> Network
 * 카카오 지도 API와 연결하는 네트워크 작업을 수행한다.
 * 필수로 전달해주어야 하는 값을 받아온다.
 * URLRequest를 받아 값을 확인하고 Observable로 data를 내뱉으며, 값을 제대로 받아왔다면 json 디코딩을 한다.
> Presentation
 * LocationInformationViewController 
   * LocationInformationViewModel과 bind 한다. 
   * 화면 상단에 받아온 API 값을 보여준다.
   * 현재 위치를 받아와 해당하는 값으로 맵을 이동시킨다.
   * 위치 서비스 허용 여부를 위한 CLLocationManager를 구현한다.
 * LocationInformationViewModel
   * 네트워크 통신으로 데이터를 불러온다.
   * 지도 중심점을 설정한다. (리스트를 선택할 때, currentLocation을 최초 받았을 때, currentLocationButton이 탭되었을 때)
 * LocationInformationModel
   * DetailListCellData에 표현해주기 위해 locationData 안에 있는 데이터를 documentData로 바꾸고, 그 데이터를 cellData로 변환한다.
   * documentData를 MTMapPoint로 변환한다.
 * DetailListCell
   * 리스트에 표현될 라벨을 설정한다.
 * DetailListBackgroundView
   * DetailListBackgroundViewModeld와 bind 한다. 
   * 리스트를 받지 못했을 경우에 나타낼 내용을 정의하며, 리스트를 받았을 경우 이 내용을 숨긴다.
 * DetailListBackgroundViewModel
   * 외부에서 전달받을 값에 따라 숨김 여부를 정한다.
> Entities
 * API로 response 받으면, 받은 json으로 전달된 데이터를 사용할 수 있도록 Entity로 만든다.

<hr>

## Unit Test
**Swift Packager로 테스트를 진행할 경우 버그가 발생할 가능성이 있기 때문에 Swift Package를 삭제한 후 Cocoapod으로 설정한다. <br> (Pod 파일 생성 후 아래와 같이 추가)**
  ```swift
  # Pods for FindCVS
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'

  target 'FindCVSTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Stubber'
    pod 'Nimble'
    pod 'RxBlocking'
    pod 'RxTest'
  end
  ``` 
* 소스코드의 특정 모듈이 개발자가 의도한대로 작동하는지 검증하는 것을 말한다.
* 앱 하나를 통째로 테스트 하는 것이 아니라 각각 작성한 메소드, 클래스 등의 단위로 테스트 케이스를 만들어 검증한다.
#### XCTest
* Xcode 프로젝트에 대한 단위 테스트, 성능 테스트, UI 테스트 등을 만들고 실행할 수 있게 하는 framework이다.
* 테스트 대상에 테스트 케이스와 테스트 메서드를 추가해서 코드가 예상대로 잘 작동하는지 확인
* XCTestCase를 상속하는 클래스를 통해 프로젝트 내에서 생성한 모델이나, 그 모델 내의 메소드들을 테스트한다.
  * 테스트 케이스, 테스트 방법, 성능 테스트 등을 정의하기 위한 기본 클래스이며, 이 클래스를 통해서 테스트를 실행하기 전에 초기 상태를 준비하고 테스트가 완료된 후에 정리까지 수행할 수 있게 된다.  
  * 대표적으로 setUp과  tearDown 메소드로 제어할 수 있다. <br>
    * setUp() : 테스트 케이스가 시작되기 전에 초기상태를 사용자 정의할 수 있는 기회를 제공한다.
    * tearDown() : 테스트 케이스 종료 후에 정리를 할 수 있는 기회를 제공한다.
    ```swift
    class func setUp()
    class func tearDown()
    ```
#### Nimble 
* XCTest framework보다 좀 더 편리하고 객관적으로 표현해주는 오픈 소스 framework이다.
* Nimble의 가장 큰 장점은 읽기 쉽다는 것이다.

#### RxTest
* Observable에 가상의 시간 개념을 주입해서 Rx코드를 테스트하는 방법이다.
	 * 시간 개념을 주입해서 언제, 무엇이 나왔는지 검증할 수 있다.
* 임의의 Observer을 통해 가상의 시간이 다 흐를 때까지 관찰한 후에 타이밍과 이벤트를 반환할 수 있다.
* 해당하는 시점에 해당하는 이벤트가 발생하는지 검증할 수 있다.
* 대표적으로 createHotObservable과 createColdObservable 메소드가 있다.
  * createHotObservable() : 구독의 여부와 관계없이 이벤트가 발생된다.
  * createColdObservable() : 구독이 시작되어야만 정해진 순서대로 이벤트가 발생될 수 있다.

#### RxBlocking
* Observable의 이벤트 방출을 검증하고, 특정 시간동안 방출된 이벤트를 검증하는 방식이다.
* Observable에서 방출된 이벤트를 단순한 Array 값으로 전환할 수 있다.

