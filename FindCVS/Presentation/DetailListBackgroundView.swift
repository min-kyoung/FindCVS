//
//  DetailListBackgroundView.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/28.
//

import RxSwift
import RxCocoa

// 리스트가 초반에 아무런 내용을 받아오지 못했을 때는 아무것도 뜨지 않을 것이다. 그렇게되면 tableView에 설정한 background가 뜨게 된다. 즉, 아무런 리스트를 찾지 못했음을 표시한다.
// 평소 리스트에 내용이 있을 때는 background의 문구를 숨긴다.

class DetailListBackgroundView: UIView {
    let disposeBag = DisposeBag()
    let statusLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: DetailListBackgroundViewModel) {
        viewModel.isStatusLabelHidden
            .emit(to: statusLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        backgroundColor = .white
        
        statusLabel.text = "🏪"
        statusLabel.textAlignment = .center
    }
    
    private func layout() {
        addSubview(statusLabel)
        
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
