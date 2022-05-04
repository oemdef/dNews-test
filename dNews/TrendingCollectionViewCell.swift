//
//  TrendingCollectionViewCell.swift
//  dNews
//
//  Created by OemDef | HansaDev on 28.04.2022.
//

import UIKit
import Alamofire
import AlamofireImage

class TrendingCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "TrendingCollectionViewCell"
    
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
        cardView.backgroundColor = ColorCompatibility.systemFill
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
    
    let blurredEffectView: UIVisualEffectView = {
        var blurEffect = UIBlurEffect()
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        } else {
            blurEffect = UIBlurEffect(style: .dark)
        }
        let blurredEffectView = UIVisualEffectView(frame: .zero)
        blurredEffectView.effect = blurEffect
        return blurredEffectView
    }()
    
    let gradientMaskLayer: CAGradientLayer = {
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.colors = [UIColor.white.withAlphaComponent(1).cgColor,
        UIColor.white.withAlphaComponent(0).cgColor]
        gradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.6)
        gradientMaskLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        return gradientMaskLayer
    }()
    
    let authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.text = "Holly Ellyatt"
        authorLabel.textColor = .white
        authorLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return authorLabel
    }()
    
    let publishedAtLabel: UILabel = {
        let publishedAtLabel = UILabel()
        publishedAtLabel.text = "4h ago"
        publishedAtLabel.textColor = .white
        publishedAtLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        publishedAtLabel.textAlignment = .right
        return publishedAtLabel
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "The threat of nuclear war is real, top Russian official says; U.S. wants to see Moscow ‘weakened’"// - CNBC"
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    let sourceLabel: UILabel = {
        let sourceLabel = UILabel()
        sourceLabel.text = "The Washington Post".uppercased()
        sourceLabel.textColor = .white
        sourceLabel.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        return sourceLabel
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cardView.addSubview(imageView)
        imageView.frame = cardView.bounds
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.addSubview(publishedAtLabel)
        publishedAtLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        //publishedAtLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        //publishedAtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        imageView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
            make.trailing.equalTo(publishedAtLabel.snp.leading).offset(-14)
            make.firstBaseline.equalTo(publishedAtLabel.snp.firstBaseline)
        }
        
        imageView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(authorLabel.snp.top).offset(-14)
        }
        
        imageView.addSubview(sourceLabel)
        sourceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(titleLabel.snp.top).offset(-6)
        }
        
        blurredEffectView.frame = imageView.bounds
        imageView.insertSubview(blurredEffectView, belowSubview: publishedAtLabel)
        blurredEffectView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(sourceLabel.snp.top).offset(-60)
        }
        blurredEffectView.layoutIfNeeded()
        gradientMaskLayer.frame = blurredEffectView.bounds
        blurredEffectView.layer.mask = gradientMaskLayer
        
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
