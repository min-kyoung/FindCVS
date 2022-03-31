//
//  LocationInformationViewModelTests.swift
//  FindCVSTests
//
//  Created by 노민경 on 2022/03/31.
//

import XCTest
import Nimble
import RxSwift
import RxTest

@testable import FindCVS

// Rx를 이용한 경우에도 RxTest를 통해서 가상의 scheduler를 만들고 그 scheduler에 따라서 observable을 생성하고 그 observable을 바라보는 observer를 만들어주어 최종적으로는 그 observer의 이벤트를 추출해 어떤 이벤트를 제대로 받았는지 확인한다.

class LocationInformationViewModelTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    let stubNetwork = LocalNetworkStub() // viewModel도 model을 받고 있기 때문에 model에서 필요한 network stub이 있어야 함
    var model: LocationInformationModel!
    var viewModel: LocationInformationViewModel!
    var doc: [KLDocument]!
    
    override func setUp() {
        self.model = LocationInformationModel(localNetwork: stubNetwork)
        self.viewModel = LocationInformationViewModel(model: model)
        self.doc = cvsList
    }
    
    func testSetMapCenter() {
        let scheduler = TestScheduler(initialClock: 0) // 0부터 시작
        
        // 더미데이터 이벤트
        let dummyDataEvent = scheduler.createHotObservable([.next(0, cvsList)]) // 생성한 더미데이터가 어떤 네트워크를 통해서 cvsList의 형태로 데이터를 뱉었다.
        
        let documentData = PublishSubject<[KLDocument]>()
        dummyDataEvent
            .subscribe(documentData)
            .disposed(by: disposeBag)
        
        // 중심점을 잡는 것은 세가지 이벤트를 받을 경우
        // DetailList 아이템(셀)이 탭되는 이벤트
        let itemSelectedEvent = scheduler.createHotObservable([
            .next(1, 0) // 1초가 지난 시점에 0번째 아이템을 탭한 경우를 가정
        ])
        
        let itemSelected = PublishSubject<Int>() // observer 역할
        
        // observable이 observer에 의해서 구독되는 모습을 테스트 코드로 구현
        itemSelectedEvent
            .subscribe(itemSelected)
            .disposed(by: disposeBag)
        
        let selecteItemMapPoint = itemSelected
            .withLatestFrom(documentData) { $1[0] } // document가 불러온 다음 시점부터 선택된 데이터가 불러온 더미데이터에 대응하는 값으로 내뱉어줄 수 있도록 함
            .map(model.documentsToMTMapPoint)
        
        // 최초 현재 위치 이벤트
        let initialMapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(37.394225), longitude: Double(127.110341)))!
        let currentLocationEvent = scheduler.createHotObservable([
            .next(0, initialMapPoint)
        ]) // initial이기 때문에 0초에 initialMapPoint가 나옴
        
        let initialCurrentLocation = PublishSubject<MTMapPoint>()
        
        currentLocationEvent
            .subscribe(initialCurrentLocation)
            .disposed(by: disposeBag)
        
        // 현재 위치 버튼 탭 이벤트
        let currentLocationButtonTapEvent = scheduler.createHotObservable([
            .next(2, Void()),
            .next(3, Void())
        ]) // 버튼을 2번 탭했을 때를 가정
        
        let currentLocationButtonTapped = PublishSubject<Void>()
        
        currentLocationButtonTapEvent
            .subscribe(currentLocationButtonTapped)
            .disposed(by: disposeBag)
        
        let moveToCurrentLocation = currentLocationButtonTapped
            .withLatestFrom(initialCurrentLocation)
        
        // 위의 세가지 이벤트에 대한 테스트를 Merge
        let currentMapCenter = Observable
            .merge(
            selecteItemMapPoint,
            initialCurrentLocation.take(1), // 최초 1번만 받음
            moveToCurrentLocation
        )
        
        // merge한 currentMapCenter를 받을 observer
        let currentMapCenterObserver = scheduler.createObserver(Double.self)
        
        currentMapCenter
            .map { $0.mapPointGeo().latitude }
            .subscribe(currentMapCenterObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let secondMapPoint = model.documentsToMTMapPoint(doc[0]) // 변환된 값이라고 가정
        
        expect(currentMapCenterObserver.events).to(
            equal([
                .next(0, initialMapPoint.mapPointGeo().latitude), // 0초에는 initialMapPoint가 나올 것이고 정확한 Double 값 비교를 위해 이를 latitude로 변환
                .next(1, secondMapPoint.mapPointGeo().latitude),
                .next(2, initialMapPoint.mapPointGeo().latitude), // 2초, 3초 후에 버튼을 눌렀을 때는 여전히 initialMapPoint가 나오게 될 것
                .next(3, initialMapPoint.mapPointGeo().latitude)
            ])
        )
    }
    
}
