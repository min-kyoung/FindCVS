//
//  LocationInformationModelTests.swift
//  FindCVSTests
//
//  Created by 노민경 on 2022/03/31.
//

import XCTest
import Nimble

@testable import FindCVS

class LocationInformationModelTests: XCTestCase {
    let stubNetwork = LocalNetworkStub()
    
    var doc: [KLDocument]!
    var model: LocationInformationModel!
    
    override func setUp() {
        self.model = LocationInformationModel(localNetwork: stubNetwork) // 실제 네트워크가 아닌 stubNetwork를 받겠다고 선언
        self.doc = cvsList
    }
    
    // LocationInformationModel에서 getLocation을 하지 않고 stub을 통해서 document가 뿌려졌다고 가정할 것이기 때문에 documentsToCellData을 테스트하는 코드를 작성한다.
    func testDocumentsToCellData() {
        let cellData = model.documentsToCellData(doc) // 실제 모델의 값
        let placeName = doc.map { $0.placeName } // doc, 즉 더미 데이터에서 가져온 값
        let address = cellData[1].address // cellData는 실제 모델이므로 실제 모델의 값
        let roadAddressName = doc[1].roadAddressName // doc에서 가져왔으므로 더미 데이터의 값
        
        
        // LocationInformationModel의 documentsToCellData 함수는 document에 있는 값들을 cellData 형식으로 전환시켜주는데, 전환을 했다고 해서 내부의 순서나 값 자체가 변경되어서는 안된다는 것을 테스트하는 것이다.
        expect(cellData.map {$0.placeName}).to(
            equal(placeName), // 가져온 값은 placeName과 같아야 함
            description: "DetailListCellData의 placeName은 document의 placeName이다.")
        
        // 더미 값으로 준 것에 실제로 도로명 주소가 있다면 도로명 주소가 그대로 내뿜어져야 된다는 것을 증명하는 것이다.
        expect(address).to(equal(roadAddressName), description: "KLDocument의 RoadAddressName이 빈 값이 아닐 경우 roadAddress가 cellData에 전달된다.")
    }

}
