//
//  LocalNetworkStub.swift
//  FindCVSTests
//
//  Created by 노민경 on 2022/03/31.
//

import Foundation
import RxSwift
import Stubber // 네트워크 변수에 의해서 에러가 발생할 수 있기 때문에, 가상의 더미 데이터를 주입해서 마치 네트워크 상에서 적절한 json 또는 response가 전달되었을 때 그것을 네트워크처럼 전달해주는 테스트를 위한 외부 라이브러리

// LocalNetwork에서 getLocation을 불러서 실제 API 콜 대신에 API 콜을 했다고 가정하고 더미 데이터를 내뿜을 수 있도록 테스트한다.
@testable import FindCVS

class LocalNetworkStub: LocalNetwork {
    override func getLocation(by mapPoint: MTMapPoint) -> Single<Result<LocationData, URLError>> {
        // 실제 함수 대신 stubber의 invoke를 통해 getLocation 함수를 실행하고 mapPoint를 argument로 갖는다.
        return Stubber.invoke(getLocation, args: mapPoint)
    }
    
}
