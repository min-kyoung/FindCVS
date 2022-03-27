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
    
    // viewModel -> view
    let setMapCenter: Signal<MTMapPoint>
    let errorMessage: Signal<String>
    
    // view -> viewModel
    let currentLocation = PublishRelay<MTMapPoint>()
    let mapCenterPoint = PublishRelay<MTMapPoint>()
    let selectedPOIItem = PublishRelay<MTMapPOIItem>()
    let mapViewError = PublishRelay<String>()
    let currentLocationButtonTapped = PublishRelay<Void>()
    
    init() {
        // 지도 중심점 설정 (센터로 이동)
        let moveToCurrentLocation = currentLocationButtonTapped
            .withLatestFrom(currentLocation) // currentLocation을 한 번이라도 받은 이후
        
        let currentMapCenter = Observable
            .merge(
                currentLocation.take(1), // currentLocation을 최초 받았을 때
                moveToCurrentLocation // currentLocationButton이 탭되었을 때
            )
        
        setMapCenter = currentMapCenter
            .asSignal(onErrorSignalWith: .empty())
        
        // 에러 메세지 전달
        errorMessage = mapViewError.asObservable()
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요.")
    }
}
