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
    
    private let documentData = PublishSubject<[KLDocument]>() // KLDocument의 리스트로 받음
    
    init(model: LocationInformationModel = LocationInformationModel()) {
        // MARK: 네트워크 통신으로 데이터 불러오기
        let cvsLocationDataResult = mapCenterPoint
            .flatMapLatest(model.getLocation) // mapCenterPoint가 view에서 viewModel로 전달될 때마다 flatMapLatest로 받아서 API 통신을 함
            .share()
        
        let cvsLocationDataValue = cvsLocationDataResult
            .compactMap { data -> LocationData? in // => compactMap을 통해 nil값을 없앰
                guard case let .success(value) = data else {
                    return nil
                }
                return value
            } // => cvsLocationDataValue가 받는 값은 LocationData가 됨
        
        // cvsLocationDataResult는 LocationData 또느 URLError를 뱉도록 설계됨
        // cvsLocationData가 value를 갖는다면 ErrorMessage도 붙을 것을 가정
        let cvsLocationDataErrorMessage = cvsLocationDataResult
            .compactMap { data -> String? in
                switch data {
                case let .success(data) where data.documents.isEmpty: // 성공이면서 document가 empty일 경우 = 성공이나 사실상 빈 값이 온 것
                    return """
                    500m 근처에 이용할 수 있는 편의점이 없습니다.
                    지도 위치를 옮겨서 재검색해주세요.
                    """
                case let .failure(error):
                    return error.localizedDescription
                default: // succsee이지만 empty가 아닌 것 = 성공 => 에러 메세지 필요 없음
                    return nil
                }
            }
        
        cvsLocationDataValue
            .map { $0.documents }
            .bind(to: documentData)
            .disposed(by: disposeBag)
        
        // MARK: 지도 중심점 설정 (센터로 이동)
        let selectDetailListItem = detailListItemSelected
            .withLatestFrom(documentData) { $1[$0] } // 받아온 documentData 중에서 selected된 row에 해당하는 값을 뽑아냄
            .map(model.documentsToMTMapPoint)
        
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
        errorMessage = Observable
            .merge(
                cvsLocationDataErrorMessage, // 네트워크에서 에러메세지가 발생했을 경우
                mapViewError.asObservable()
            )
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요.")
        
        detailListCellData = documentData // documentData가 들어오기 시작하면
            .map(model.documentsToCellData) // model에서 documentsToCellData 함수를 지나서
            .asDriver(onErrorDriveWith: .empty()) // driver로 만들어줌
        
        documentData
            .map { !$0.isEmpty } // 비어있지 않다면
            .bind(to: detailListBackgroundViewModel.shouldHideStatusLabel) // 데이터에 따라 subview인 backgroundview까지 한번에 연결
            .disposed(by: disposeBag)
        
        scrollToSelectedLocation = selectedPOIItem // 핀을 선택했을 때 발생하는 이벤트
            .map { $0.tag } // tag로 전환
            .asSignal(onErrorJustReturn: 0)
    }
}

