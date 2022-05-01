//
//  DetailsViewController.swift
//  dNews
//
//  Created by OemDef | HansaDev on 30.04.2022.
//

import UIKit
import SnapKit
import SafariServices

class DetailsViewController: UIViewController {
    
    
    var article: Article? = nil {
        didSet {
            
            if let article = article {
                //imageView.image = UIImage(data: fetchImageFromURL(article.urlToImage))
                sourceLabel.text = article.source.name?.uppercased()
                titleLabel.text = article.title//.components(separatedBy: "-")[0]
                authorLabel.text = article.author?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? "\(article.source.name!) Team"
                            
                imageView.af.setImage(withURL: URL(string: (article.urlToImage)!)!)

                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.date(from:article.publishedAt!)!
                
                publishedAtLabel.text = date.timeAgoDisplay()
                
                contentLabel.text = article.content?.components(separatedBy: "[")[0]
            }
            
            // Update views here
        }
    }
    
    let containerView = UIView()
        
    let scrollView = UIScrollView()
    let openSafariButton = UIButton()
    
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
        authorLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        return authorLabel
    }()
    
    let publishedAtLabel: UILabel = {
        let publishedAtLabel = UILabel()
        publishedAtLabel.text = "4h ago"
        //publishedAtLabel.textColor = .white
        publishedAtLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        publishedAtLabel.textAlignment = .right
        publishedAtLabel.translatesAutoresizingMaskIntoConstraints = false
        return publishedAtLabel
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "The threat of nuclear war is real, top Russian official says; U.S. wants to see Moscow ‘weakened’"// - CNBC"
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //titleLabel.textColor = .white
        return titleLabel
    }()
    
    let sourceLabel: UILabel = {
        let sourceLabel = UILabel()
        sourceLabel.text = "The Washington Post".uppercased()
        //sourceLabel.textColor = .white
        sourceLabel.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        return sourceLabel
    }()
    
    let contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.text = "Article content placeholder"
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        return contentLabel
    }()
    
    let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(1).cgColor,
        UIColor.black.withAlphaComponent(0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.6)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        return gradientLayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.modalPresentationCapturesStatusBarAppearance = true

        view.backgroundColor = .systemBackground
        
        self.navigationItem.title = article?.source.name!.uppercased()
        //self.navigationItem.app
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .heavy)]
        self.navigationItem.largeTitleDisplayMode = .never
        //self.navigationController?.navigationBar.tintColor = .white
        //self.navigationController?.navigationBar.barStyle = .black
        
        
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.cornerStyle = .large
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
          var outgoing = incoming
          outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
          return outgoing
        }
        config.title = "Read more on the Web"
        config.image = UIImage(systemName: "chevron.right")
        config.imagePadding = 5
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage
          = UIImage.SymbolConfiguration(scale: .medium)
        openSafariButton.configuration = config


        
        
        openSafariButton.addAction(
            UIAction {_ in
                guard let link = URL(string: (self.article?.url)!) else {
                  print("Invalid link")
                  return
                }
                let safariViewController = SFSafariViewController(url: link)
                self.present(safariViewController, animated: true, completion: nil)
            }, for: .touchUpInside)
        
        
        view.addSubview(openSafariButton)
        openSafariButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(40)
            //make.top.equalTo(contentLabel.snp.bottom).offset(20)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        
        view.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(openSafariButton.snp.top).offset(-20)
            //make.top.equalTo(publishedAtLabel.snp.bottom).offset(20)
        }
        
        view.addSubview(publishedAtLabel)
        publishedAtLabel.snp.makeConstraints { make in
            //make.firstBaseline.equalTo(authorLabel.snp.firstBaseline)
            make.bottom.equalTo(contentLabel.snp.top).offset(-20)
            //make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            //make.top.equalTo(titleLabel.snp.bottom).offset(14)
            //make.bottom.equalToSuperview().inset(20)
            make.trailing.equalTo(publishedAtLabel.snp.leading).offset(-14)
            make.firstBaseline.equalTo(publishedAtLabel.snp.firstBaseline)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(authorLabel.snp.top).offset(-14)
        }
        
        /*view.addSubview(sourceLabel)
        sourceLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.top).offset(-6)
            make.leading.equalToSuperview().inset(20)
            //make.top.equalTo(imageView.snp.bottom).offset(20)
        }*/
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)//.offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-20)
        }
        
        containerView.layoutIfNeeded()

        containerView.addSubview(imageView)
        imageView.frame = containerView.bounds
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

}

extension DetailsViewController: SFSafariViewControllerDelegate {
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true, completion: nil)
  }
}
