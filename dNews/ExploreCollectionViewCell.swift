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
    
    var article: Article? = nil {
        didSet {
            
            if let article = article {
                //imageView.image = UIImage(data: fetchImageFromURL(article.urlToImage))
                sourceLabel.text = article.source.name?.uppercased()
                titleLabel.text = article.title//.components(separatedBy: "-")[0]
                var authorLabelText = article.author?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? "\(article.source.name!) Team"
                if authorLabelText.isEmpty {
                    authorLabelText = "\(article.source.name!) Team"
                }
                authorLabel.text = authorLabelText
                
                getImage(for: article.urlToImage ?? "noImage")
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from:article.publishedAt!)!
                
                publishedAtLabel.text = date.timeAgoDisplay()
                
            }
            // Update views here
        }
    }
    
    //func configure(with)
    
    
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
        //authorLabel.textColor = .white
        authorLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return authorLabel
    }()
    
    let publishedAtLabel: UILabel = {
        let publishedAtLabel = UILabel()
        publishedAtLabel.text = "4h ago"
        //publishedAtLabel.textColor = .white
        publishedAtLabel.textAlignment = .right
        publishedAtLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return publishedAtLabel
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "The threat of nuclear war is real, top Russian official says; U.S. wants to see Moscow ‘weakened’"// - CNBC"
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.systemFont(ofSize: 14.5, weight: .heavy)
        //titleLabel.textColor = .white
        return titleLabel
    }()
    
    let sourceLabel: UILabel = {
        let sourceLabel = UILabel()
        sourceLabel.text = "The Washington Post".uppercased()
        //sourceLabel.textColor = .white
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
        publishedAtLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        
        cardView.addSubview(authorLabel)
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
            //make.bottom.equalTo(titleLabel.snp.top).offset(-6)
        }
        
        
        
        
        
        cardView.layoutIfNeeded()
        
        let cardRoundPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 20)
        let cardMaskLayer = CAShapeLayer()
        cardMaskLayer.frame = cardView.layer.bounds
        cardMaskLayer.path = cardRoundPath.cgPath
        cardView.layer.mask = cardMaskLayer
        
        /*let cardShadowLayer = CAShapeLayer()
        cardShadowLayer.path = cardRoundPath.cgPath
        cardShadowLayer.frame = cardView.layer.bounds
        cardView.layer.backgroundColor = UIColor.clear.cgColor
        cardView.layer.insertSublayer(cardShadowLayer, at: 0)
        cardShadowLayer.backgroundColor = UIColor.clear.cgColor
        cardShadowLayer.shadowOffset = .zero
        cardShadowLayer.shadowColor = UIColor.tertiarySystemFill.cgColor
        cardShadowLayer.shadowRadius = 8
        cardShadowLayer.shadowOpacity = 0.6
        cardShadowLayer.shadowPath = cardRoundPath.cgPath*/
    
    }
    
    private func getImage(for url: String) {
        AF.request(url)
            .responseImage { response in
                if case .success(let image) = response.result {
                    self.imageView.image = image
                } else {
                    self.imageView.image = UIImage(named: "placeholder")
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
