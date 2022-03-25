//
//  DetailListCellData.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/25.
//

import Foundation

// 셀에 필요한 내용
struct DetailListCellData {
    let placeName: String
    let address: String
    let distance: String
    let point: MTMapPoint // 리스트를 탭했을 때, 해당하는 x, y 좌표값을 맵에 전달해서 편의점을 지정할 수 있게 함 (셀이 전달해줄 방식)
}
