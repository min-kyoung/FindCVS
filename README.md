# FindCVS
## Description
* Rx, MVVM 구조, 카카오의 OpenAPI인 Local API, 애플 CLLocationManager를 활용하여 내 근처 편의점을 나타내주는 프로젝트이다.
* 상단에는 카카오 맵을 띄우고 빨간색 핀으로 어디에 편의점에 위치해있는지 보여주며 하단에는 편의점의 목록을 보여준다.
* 맵과 리스트의 데이터는 Rx binding을 통해서 연결할 것이다. 따라서 핀을 선택하면 해당 편의점을 리스트에서도 보여주고, 리스트의 편의점을 선택해도 해당 편의점이 맵의 중심에 오도록 맵을 이동한다.
* 가까운 곳에 편의점이 없거나 에러가 발생하면 AlertController를 통해 어떠한 에러가 발생했는지 표시한다.
## Prerequisite
* Kakao API를 사용하기 위해 **https://developers.kakao.com** 에 로그인을 한다.
  * **내 애플리케이션**을 추가한다.
  * **문서 > 지도/로컬 API 가이드 > iOS > Guide**에서 SDK를 다운받는다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227094-5c1f8d86-ebc4-4051-8251-2d0e96376fc2.png" width="450" height="170"> 　
* Kakao Map API 연결 
  * 번들 ID와 일치하는 앱에서만 지도 API를 사용할 수 있도록 네이티브엡키를 info.plist에 추가
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227110-2c7b7322-83d5-465c-a7b3-d9ede433966f.png" width="550" height="30"> 　
  * DaumMap framework를 사용하려면 이 외에도 다른 framework를 수동으로 처리해주어야 한다. 이 전에는 cocoapod이나 swift package 매니저를 설치하여 자동적으로 해결이 되었다면, 지도 SDK가 그러한 툴을 제공하지 않기 때문에 다른 framework를 수동으로 추가한다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227227-36e40ce9-9832-4598-8a45-e7894e8f03e4.png" width="550" height="170"> 　
  * Mac용 SDK는 ARC를 지원하지 않기 때문에 NO로 변경 후 저장한다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227230-ae02801d-bcbe-4e04-821f-595cd928b1c7.png" width="550" height="60"> 　
  * SDK는 Object-C로 되어있기 때문에 Swift에서 사용하기 위해 BridgingHeader를 추가한다.
  * 추가한 BridgingHeader를 XCode가 확인할 수 있도록 BridgingHeader의 path를 입력한다.
  <br> <img src="https://user-images.githubusercontent.com/62936197/160227231-0c0fc194-0c89-4286-9731-a94d7a02c979.png" width="550" height="70"> 　
## Usage
#### 카카오의  OpenAPI인 Local API 
* 카카오의 지도 SDK를 기반으로 iOS, Android 등의 플랫폼 서비스에서 카카오 맵을 활용할 수 있도록 다양한 메서드와 라이브러리를 통한 커스텀 기능을 제공한다.
#### 애플의 CLLocationManager 
* 사용자의 위치는 개인적인 정보이므로 앱에서 위치관련 이벤트를 활용하기 위해서는 사용자의 허락이 필요하다. 
* CLLocationManager는 앱에 대한 위치 관련 이벤트 전달을 시작하거나 중지하는데 사용하는 객체이다. 
* 앱에 위치 서비스를 추가하려면 CLLocationManager를 사용해서 Delegate를 구현하고 앱에 필요한 위치 정보에 엑세스할 수 있는 권한을 부여할지 여부를 결정하면 된다.
