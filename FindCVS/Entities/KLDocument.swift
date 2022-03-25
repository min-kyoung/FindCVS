//
//  KLDocument.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/25.
//

import Foundation

// 이 데이터들은 받아서 셀에 뿌려지게 될 것
struct KLDocument: Decodable {
    let placeName: String
    let addressName: String
    let roadAddressName: String
    let x: String
    let y: String
    let distance: String
    
    enum CodingKeys: String, CodingKey {
        case x, y, distance
        case placeName = "place_name"
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
    }
}
