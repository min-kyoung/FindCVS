//
//  LocationInformationViewController.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/27.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit

class LocationInformationViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    let mapView = MTMapView()
    let currentLocationButton = UIButton() // 현재 위치를 표시해주는 버튼
    let detailList = UITableView()
    
    let detailListBackgroundView = DetailListBackgroundView()
    let viewModel = LocationInformationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        bind(viewModel)
        attribute()
        layout()
    }
    
    private func bind(_ viewModel: LocationInformationViewModel) {
        detailListBackgroundView.bind(viewModel.detailListBackgroundViewModel)
        
        // 센터 포인트 값을 받았으니 해당하는 값으로 맵을 이동시키라고 명령을 주는 것
        viewModel.setMapCenter
            .emit(to: mapView.rx.setMapCenterPoint)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .emit(to: self.rx.presentAlert)
            .disposed(by: disposeBag)
        
        viewModel.detailListCellData
            .drive(detailList.rx.items) { tv, row, data in
                let cell = tv.dequeueReusableCell(withIdentifier: "DetailListCell", for: IndexPath(row: row, section: 0)) as! DetailListCell
                
                cell.setData(data)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        // 맵 뷰에서 핀을 뿌려줌 => 핀이 어디에 위치할지 정확한 위치를 알아야 함
        viewModel.detailListCellData
            .map { $0.compactMap { $0.point} } // detailListCellData는 DetailListCellData의 array인데, addPOItems는 바로 MTMapPoint를 받도록 했기 때문에 compactMap을 통해 point 값만 뽑아서 전달될 수 있게 함
            .drive(self.rx.addPOItems)
            .disposed(by: disposeBag)
        
        // SelectedLocation으로 스크롤을 했을 때, 어떠한 location이 selected 되었는지 리스트로 보여주어야 함
        viewModel.scrollToSelectedLocation
            .emit(to: self.rx.showSelectedLocation)
            .disposed(by: disposeBag)
        
        detailList.rx.itemSelected
            .map { $0.row } // row 값만 뽑음
            .bind(to: viewModel.detailListItemSelected)
            .disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .bind(to: viewModel.currentLocationButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        title = "내 주변 편의점 찾기"
        view.backgroundColor = .white
        
        mapView.currentLocationTrackingMode = .onWithHeadingWithoutMapMoving // 현재 트래킹 모드 및 나침반 모드
        
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocationButton.backgroundColor = .white
        currentLocationButton.layer.cornerRadius = 20
        
        detailList.register(DetailListCell.self, forCellReuseIdentifier: "DetailListCell")
        detailList.separatorStyle = .none
        detailList.backgroundView = detailListBackgroundView
    }
    
    private func layout() {
        [mapView, currentLocationButton, detailList]
            .forEach { view.addSubview($0) }
        
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide) // navigation 하단에 위치
            $0.bottom.equalTo(view.snp.centerY).offset(100)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.bottom.equalTo(detailList.snp.top).offset(-12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(40)
        }
        
        detailList.snp.makeConstraints {
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(0)
            $0.top.equalTo(mapView.snp.bottom)
        }
    }
}

extension LocationInformationViewController: CLLocationManagerDelegate {
    // 사용자가 위치 서비스를 택하도록 하는 승인을 했는지, 승인을 얻지 못했다면 어떠한 설정을 할 수 있도록 하는지를 구현
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, // 항상 허용
                .authorizedWhenInUse, // 사용할 때만 허용
                .notDetermined: // 별도의 언급이 없었을 경우
            return
        default: // 승인 획득 실패 => 에러
            viewModel.mapViewError.accept(MTMapViewError.locationAuthorizationDenied.errorDescription)
            return
        }
    }
}


// 시뮬레이터에서는 자신의 현재 위치를 정확하게 받아올 수 없기 때문에, 디버그 모드일 때와 그렇지 않을 때에 대해서 임의의 좌표값을 입력해주어야 한다.
extension LocationInformationViewController: MTMapViewDelegate {
    // updateCurrentLocation : 현재 위치를 매번 업데이트 해주는 delegate
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        #if DEBUG
        viewModel.currentLocation.accept(MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.394225, longitude: 127.110341))) // 임의의 좌표값
        #else
        viewModel.currenLocation.accept(loacation) // currenLocation point를 그대로 받을 수 있도록 함
        #endif
    }
    
    // 맵의 이동이 끝났을 때, 마지막의 센터 포인트를 전달한다.
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        viewModel.mapCenterPoint.accept(mapCenterPoint)
    }
    
    // 핀으로 표시된 아이템을 탭할 때마다 해당하는 아이템의 MTMap 포인트 값을 전달해준다.
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        viewModel.selectedPOIItem.accept(poiItem)
        return false
    }
    
    // 제대로된 현재 위치를 불러오지 못했을 때 에러를 내뱉는다.
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
        viewModel.mapViewError.accept(error.localizedDescription)
    }
}

// MTMapView에서 활용되는 MapCenter를 Rx extension으로 커스텀해서 만든 곳으로 이어질 수 있게 함
extension Reactive where Base: MTMapView {
    var setMapCenterPoint: Binder<MTMapPoint> {
        return Binder(base) { base, point in
            base.setMapCenter(point, animated: true)
        }
    }
}

extension Reactive where Base: LocationInformationViewController {
    var presentAlert: Binder<String> {
        return Binder(base) { base, message in
            let alertController = UIAlertController(title: "문제가 발생했어요.", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alertController.addAction(action)
            
            base.present(alertController, animated: true, completion: nil)
        }
    }
    
    var showSelectedLocation: Binder<Int> {
        return Binder(base) { base, row in
            let indexPath = IndexPath(row: row, section: 0)
            base.detailList.selectRow(at: indexPath, animated: true, scrollPosition: .top) // detailList가 해당 이벤트가 들어올 때마다 선택된 어떠한 리스트로 해당하는 것이 가장 위에 뜨게 자동으로 이동하게 해줄 것
            // detailList는 UITableView에 있는 기본적인 메서드로, 어떠한 indexPath로 이동하라는 것만 알려주면  자동적으로 이동시켜줌
        }
    }
    
    var addPOItems: Binder<[MTMapPoint]> {
        return Binder(base) { base, points in
            let items = points
                .enumerated()
                .map { offset, point -> MTMapPOIItem in // enumerated를 통해 offset과 point로 나누어서 보여진 것을 MTMapPOIItem으로 만듦
                    let mapPOItem = MTMapPOIItem()
                    
                    mapPOItem.mapPoint = point
                    mapPOItem.markerType = .redPin
                    mapPOItem.showAnimationType = .springFromGround
                    mapPOItem.tag = offset // 고유한 tag를 가지도록 함
                    
                    return mapPOItem
                }
            base.mapView.removeAllPOIItems() // 새로운 이벤트를 받을 때마다 기존의 아이템은 다 지우고
            base.mapView.addPOIItems(items) // 새로운 아이템을 추가함
        }
    }
}
