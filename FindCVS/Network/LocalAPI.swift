//
//  LocalAPI.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/29.
//

import Foundation

struct LocalAPI {
    static let scheme = "https"
    static let host = "dapi.kakao.com"
    static let path = "/v2/local/search/category.json"
    
    func getLocation(by mapPoint: MTMapPoint) -> URLComponents {
        var components = URLComponents()
        components.scheme = LocalAPI.scheme
        components.host = LocalAPI.host
        components.path = LocalAPI.path
        
        // 필수로 전달해주어야 하는 값들
        components.queryItems = [
            URLQueryItem(name: "category_group_code", value: "CS2"),
            URLQueryItem(name: "x", value: "\(mapPoint.mapPointGeo().longitude)"),
            URLQueryItem(name: "y", value: "\(mapPoint.mapPointGeo().latitude)"),
            URLQueryItem(name: "radius", value: "500"), // 500m
            URLQueryItem(name: "sort", value: "distance") // 거리순으로 정렬
        ]
        
        return components
    }
}
