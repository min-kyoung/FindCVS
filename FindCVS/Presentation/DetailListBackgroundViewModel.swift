//
//  DetailListBackgroundViewModel.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/28.
//

import RxSwift
import RxCocoa

struct DetailListBackgroundViewModel {
    // viewModel -> view
    let isStatusLabelHidden: Signal<Bool>  // 만약 리스트에 가지고 온 데이터가 있다면 숨겨져야 하고, 아무런 데이터가 없다면 보여져야 한다.
    
    // 외부에서 전달받을 값
    let shouldHideStatusLabel = PublishSubject<Bool>()
    
    init() {
        isStatusLabelHidden = shouldHideStatusLabel
            .asSignal(onErrorJustReturn: true)
    }
}
