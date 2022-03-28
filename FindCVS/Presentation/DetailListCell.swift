//
//  DetailListCell.swift
//  FindCVS
//
//  Created by 노민경 on 2022/03/28.
//

import UIKit

class DetailListCell: UITableViewCell {
    let placeNameLabel = UILabel()
    let addressLabel = UILabel()
    let distanceLabel = UILabel() // 중심에서 어느정도 떨어져 있는지를 나타낼 라벨
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(_ data: DetailListCellData) {
        // 각각의 내용을 받았을 때 각각의 라벨에 텍스트 형식으로 표현될 수 있게 함
        placeNameLabel.text = data.placeName
        addressLabel.text = data.address
        distanceLabel.text = data.distance
    }
    
    private func attribute() {
        backgroundColor = .white
        placeNameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .gray
        
        distanceLabel.font = .systemFont(ofSize: 12, weight: .light)
        distanceLabel.textColor = .darkGray
    }
    
    private func layout() {
        [placeNameLabel, addressLabel, distanceLabel]
            .forEach { contentView.addSubview($0) }
        
        placeNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(placeNameLabel.snp.bottom).offset(3)
            $0.leading.equalTo(placeNameLabel)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
}
