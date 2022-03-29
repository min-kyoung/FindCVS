//
//  LocalNetwork.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/29.
//

import RxSwift

class LocalNetwork {
    private let session: URLSession
    let api = LocalAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getLocation(by mapPoint: MTMapPoint) -> Single<Result<LocationData, URLError>> {
        let appid = Bundle.main.apiKey
        
        guard let url = api.getLocation(by: mapPoint).url else {
            return .just(.failure(URLError(.badURL)))
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK \(appid)", forHTTPHeaderField: "Authorization")
        
        
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do { // jSON 디코딩
                    let locationData = try JSONDecoder().decode(LocationData.self, from: data)
                    return .success(locationData)
                } catch {
                    return .failure(URLError(.cannotParseResponse))
                }
            }
            .catch{ _ in .just(Result.failure(URLError(.cannotLoadFromNetwork)))}
            .asSingle() // => 성공 또는 실패에 대해서만 내뱉는 single observable로 변환
    }
}
