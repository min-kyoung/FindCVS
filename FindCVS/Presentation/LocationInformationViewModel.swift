//
//  LocationInformationViewModel.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/27.
//

import RxSwift
import RxCocoa

struct LocationInformationViewModel {
    let disposeBag = DisposeBag()
    
    // subViewModels
    let detailListBackgroundViewModel = DetailListBackgroundViewModel()
    
    // viewModel -> view
    let setMapCenter: Signal<MTMapPoint>
    let errorMessage: Signal<String>
    
    let detailListCellData: Driver<[DetailListCellData]> // API 통신을 통해 받아왔을 때 전달해 줄 것
    let scrollToSelectedLocation: Signal<Int> // 특정 위치에 있는 마커를 눌렀을 때, 리스트가 이동해서 해당하는 것이 어떠한 편의점인지 표시하게 될 것
    
    // view -> viewModel
    let currentLocation = PublishRelay<MTMapPoint>()
    let mapCenterPoint = PublishRelay<MTMapPoint>()
    let selectedPOIItem = PublishRelay<MTMapPOIItem>()
    let mapViewError = PublishRelay<String>()
    let currentLocationButtonTapped = PublishRelay<Void>()

    let detailListItemSelected = PublishRelay<Int>() // 리스트가 선택되었을 때 어떠한 row값이 전달되도록 함
    
    let documentData = PublishSubject<[KLDocument?]>() // KLDocument의 리스트로 받음
    
    init() {
        // 지도 중심점 설정 (센터로 이동)
        
        let selectDetailListItem = detailListItemSelected
            .withLatestFrom(documentData) { $1[$0] } // 받아온 documentData 중에서 selected된 row에 해당하는 값을 뽑아냄
            .map { data -> MTMapPoint in // 데이터가 뽑아지면 MTMapPoint로 변혼
                guard let data = data,
                      let longtitue = Double(data.x), // 경도 값으로 변경
                      let latituude = Double(data.y) // 위도 값으로 변경
                else {
                    return MTMapPoint()
                }
                let geoCord = MTMapPointGeo(latitude: latituude, longitude: longtitue)
                return MTMapPoint(geoCoord: geoCord) // 정확한 포인트 값으로 변환
            }
        
        let moveToCurrentLocation = currentLocationButtonTapped
            .withLatestFrom(currentLocation) // currentLocation을 한 번이라도 받은 이후
        
        let currentMapCenter = Observable
            .merge(
                selectDetailListItem, // 리스트를 선택할 때
                currentLocation.take(1), // currentLocation을 최초 받았을 때
                moveToCurrentLocation // currentLocationButton이 탭되었을 때
            ) // => 맵 이동
        
        setMapCenter = currentMapCenter
            .asSignal(onErrorSignalWith: .empty())
        
        // 에러 메세지 전달
        errorMessage = mapViewError.asObservable()
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요.")
        
        // * API통신을 아직 하지 않았기 때문에 임의로 빈값을 전달할 수 있도록 함
        detailListCellData = Driver.just([])
        
        scrollToSelectedLocation = selectedPOIItem // 핀을 선택했을 때 발생하는 이벤트
            .map { $0.tag } // tag로 전환
            .asSignal(onErrorJustReturn: 0)
    }
}

