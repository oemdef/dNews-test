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
                    guard URL(string: viewModel.urlToImage) != nil else { return }
                    imageView.af.setImage(withURL: URL(string: viewModel.urlToImage)!, placeholderImage: UIImage(named: "placeholder"))
                }
                publishedAtLabel.text = viewModel.publishedAgo
            }
        }
    }
    
    var fontScaleConst: CGFloat? = nil {
        didSet {
            if fontScaleConst != nil {
                rescaleFont()
            }
        }
    }
    
    var marginConst: CGFloat? = nil {
        didSet {
            if marginConst != nil {
                reconstraint()
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
    
    let authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.text = "Holly Ellyatt"
        authorLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        return authorLabel
    }()
    
    let publishedAtLabel: UILabel = {
        let publishedAtLabel = UILabel()
        publishedAtLabel.text = "4h ago"
        publishedAtLabel.textAlignment = .right
        publishedAtLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        publishedAtLabel.translatesAutoresizingMaskIntoConstraints = false
        return publishedAtLabel
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "The threat of nuclear war is real, top Russian official says; U.S. wants to see Moscow ‘weakened’"// - CNBC"
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.systemFont(ofSize: 14.5, weight: .heavy)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let sourceLabel: UILabel = {
        let sourceLabel = UILabel()
        sourceLabel.text = "The Washington Post".uppercased()
        sourceLabel.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        return sourceLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardView)
        cardView.addSubview(imageView)
        cardView.addSubview(sourceLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(publishedAtLabel)
        cardView.addSubview(authorLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.frame = cardView.bounds
        imageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(cardView.snp.height)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.bottom.equalToSuperview().inset(10)
        }
        
        publishedAtLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(authorLabel.snp.trailing).offset(10).priority(.high)
        }
        publishedAtLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    
        sourceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10).priority(.required)
            make.leading.equalTo(authorLabel.snp.leading)
            make.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(sourceLabel.snp.bottom)
            make.bottom.equalTo(authorLabel.snp.top).priority(.high)
        }
        
        authorLabel.setContentHuggingPriority(.required + 1, for: .vertical)
        sourceLabel.setContentHuggingPriority(.required + 1, for: .vertical)
        
        cardView.layoutIfNeeded()
        
        let cardRoundPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 20)
        let cardMaskLayer = CAShapeLayer()
        cardMaskLayer.frame = cardView.layer.bounds
        cardMaskLayer.path = cardRoundPath.cgPath
        cardView.layer.mask = cardMaskLayer
    }
    
    convenience init (frame: CGRect, passedMarginsConst: CGFloat, passedFontScaleConst: CGFloat) {
        self.init(frame: frame)
        self.marginConst = passedMarginsConst
        self.fontScaleConst = passedFontScaleConst
        rescaleFont()
        reconstraint()
    }
    
    func rescaleFont() {
        if fontScaleConst != nil {
            authorLabel.font = UIFont.systemFont(ofSize: 12 * fontScaleConst!, weight: .bold)
            publishedAtLabel.font = UIFont.systemFont(ofSize: 12 * fontScaleConst!, weight: .semibold)
            titleLabel.font = UIFont.systemFont(ofSize: 14.5 * fontScaleConst!, weight: .heavy)
            sourceLabel.font = UIFont.systemFont(ofSize: 12 * fontScaleConst!, weight: .heavy)
        }
    }
    
    func reconstraint() {
        if marginConst != nil {
            authorLabel.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(marginConst!/2)
            }
            
            publishedAtLabel.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(marginConst!/2)
                make.trailing.equalToSuperview().inset(marginConst!)
                make.leading.equalTo(authorLabel.snp.trailing).offset(marginConst!/2).priority(.high)
            }
        
            sourceLabel.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(marginConst!/2).priority(.required)
                make.trailing.equalToSuperview().inset(marginConst!)
            }
            
            titleLabel.snp.updateConstraints { make in
                make.leading.equalTo(imageView.snp.trailing).offset(marginConst!)
                make.trailing.equalToSuperview().inset(marginConst!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(named: "placeholder")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
