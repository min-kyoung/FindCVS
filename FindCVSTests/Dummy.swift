//
//  Dummy.swift
//  FindCVSTests
//
//  Created by 노민경 on 2022/03/31.
//

import Foundation

// json 형태의 파일을 받으면 원하는 방식으로 디코딩

@testable import FindCVS

var cvsList: [KLDocument] = Dummy().load("networkDummy.json")

class Dummy {
    func load<T: Decodable>(_ filename: String) -> T {
        let data: Data
        let bundle = Bundle(for: type(of: self))
        
        guard let file = bundle.url(forResource: filename, withExtension: nil) else {
            fatalError("\(filename)을 main bundle에서 불러올 수 없습니다.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("\(filename)을 main bundle에서 불러올 수 없습니다.")
        }
        
        // 통과했다면 디코더 사용 가능
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("\(filename)을 \(T.self)로 파싱할 수 없습니다.")
        }
    }
}
