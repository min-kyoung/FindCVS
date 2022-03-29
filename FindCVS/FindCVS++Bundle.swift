//
//  FindCVS++Bundle.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/29.
//

import Foundation

extension Bundle {
    var apiKey: String {
        guard let file = self.path(forResource: "MapAPIInfo", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["API_KEY"] as? String else { fatalError("MapAPIInfodp.plist에 API_KEY 설정을 해주세요.")}
        return key
    }
}
