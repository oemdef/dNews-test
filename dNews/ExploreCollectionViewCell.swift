//
//  ExploreCollectionViewCell.swift
//  dNews
//
//  Created by OemDef | HansaDev on 30.04.2022.
//

import UIKit
import Alamofire
import AlamofireImage

class ExploreCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "ExploreCollectionViewCell"
    
    var viewModel: ArticleViewModel? = nil {
        didSet {
            if let viewModel = viewModel {
                sourceLabel.text = viewModel.source.name?.uppercased()
                titleLabel.text = viewModel.title
                authorLabel.text = viewModel.author
                if viewModel.urlToImage != "No URL to Image" {
                    imageView.af.setImage(withURL: URL(string: viewModel.urlToImage)!, placeholderImage: UIImage(named: "placeholder"))
                }
                publishedAtLabel.text = viewModel.publishedAgo
            }
        }
    }
    
    let cardView: UIView = {
        let cardView = UIView()
        cardView.backgroundColor = .systemFill
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.text = "Holly Ellyatt"
        authorLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return authorLabel
    }()
    
    let publishedAtLabel: UILabel = {
        let publishedAtLabel = UILabel()
        publishedAtLabel.text = "4h ago"
        publishedAtLabel.textAlignment = .right
        publishedAtLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return publishedAtLabel
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "The threat of nuclear war is real, top Russian official says; U.S. wants to see Moscow ‘weakened’"// - CNBC"
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.systemFont(ofSize: 14.5, weight: .heavy)
        return titleLabel
    }()
    
    let sourceLabel: UILabel = {
        let sourceLabel = UILabel()
        sourceLabel.text = "The Washington Post".uppercased()
        sourceLabel.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        return sourceLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        cardView.addSubview(imageView)
        imageView.frame = cardView.bounds
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(cardView.snp.height)
        }
        
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        cardView.addSubview(publishedAtLabel)
        cardView.addSubview(authorLabel)
        
        publishedAtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        publishedAtLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(authorLabel.snp.trailing).offset(10)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalTo(publishedAtLabel.snp.leading).offset(-10)
            make.firstBaseline.equalTo(publishedAtLabel.snp.firstBaseline)
        }
        
        
        
        cardView.addSubview(sourceLabel)
        sourceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(authorLabel.snp.leading)
            make.trailing.equalToSuperview().inset(20)
        }
        
        cardView.layoutIfNeeded()
        
        let cardRoundPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 20)
        let cardMaskLayer = CAShapeLayer()
        cardMaskLayer.frame = cardView.layer.bounds
        cardMaskLayer.path = cardRoundPath.cgPath
        cardView.layer.mask = cardMaskLayer
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(named: "placeholder")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
