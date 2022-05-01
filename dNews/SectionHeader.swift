//
//  SectionHeader.swift
//  dNews
//
//  Created by OemDef | HansaDev on 30.04.2022.
//

import UIKit
import SnapKit

class SectionHeader: UICollectionReusableView {
    
    static let reuseId = "SectionHeader"
    
    let title = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customiseElements()
        setupConstraints()
    }
    
    private func customiseElements() {
        title.textColor = .label
        title.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        addSubview(title)
        title.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
