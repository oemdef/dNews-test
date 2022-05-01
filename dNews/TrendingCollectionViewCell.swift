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
    
    var article: Article? = nil {
        didSet {
            
            if let article = article {
                //imageView.image = UIImage(data: fetchImageFromURL(article.urlToImage))
                sourceLabel.text = article.source.name?.uppercased()
                titleLabel.text = article.title//.components(separatedBy: "-")[0]
                authorLabel.text = article.author?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? "\(article.source.name!) Team"
                            
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
    
    let blurredEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
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
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        cardView.addSubview(imageView)
        imageView.frame = cardView.bounds
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        imageView.addSubview(publishedAtLabel)
        publishedAtLabel.snp.makeConstraints { make in
            //make.firstBaseline.equalTo(authorLabel.snp.firstBaseline)
            make.bottom.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(named: "placeholder")
    }
    
    private func loadImage(for url: URL) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil, (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("❗️Network error – \(error!)")
                return
            }
            DispatchQueue.main.async() { [weak self] in
                self?.imageView.image = UIImage(data: data)
            }
        }
        dataTask.resume()
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
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
}
