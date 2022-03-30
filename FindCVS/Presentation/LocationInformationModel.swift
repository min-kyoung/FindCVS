//
//  LocationInformationModel.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/29.
//

import Foundation
import RxSwift

struct LocationInformationModel {
    let localNetwork: LocalNetwork
    
    init(localNetwork: LocalNetwork = LocalNetwork()) {
        self.localNetwork = localNetwork
    }
    
    func getLocation(by mapPoint: MTMapPoint) -> Single<Result<LocationData, URLError>> {
        return localNetwork.getLocation(by: mapPoint)
    }
    
    // locationData 안에 있는 documentData가 필요하므로 documentData로 바꾸고, 그 데이터를 cellData로 변환
    func documentsToCellData(_ data: [KLDocument]) -> [DetailListCellData] {
        return data.map {
            let address = $0.roadAddressName.isEmpty ? $0.addressName : $0.roadAddressName // 도로명주소가 없는 경우 지번주소로 내뱉음
            let point = documentsToMTMapPoint($0)
            return DetailListCellData(placeName: $0.placeName, address: address, distance: $0.distance, point: point)
            
        }
    }
    
    // documentData를 MTMapPoint로 변환수는 함수
    func documentsToMTMapPoint(_ doc: KLDocument) -> MTMapPoint {
        let latitude = Double(doc.y) ?? .zero // x값은 String으로 들어오기 때문에 Double로 변환
        let longitude = Double(doc.x) ?? .zero
        return MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude))
    }
}
