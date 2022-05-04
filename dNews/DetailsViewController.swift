//
//  DetailsViewController.swift
//  dNews
//
//  Created by OemDef | HansaDev on 30.04.2022.
//

import UIKit
import SnapKit
import Alamofire
import SafariServices

class DetailsViewController: UIViewController {
    
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
                contentLabel.text = viewModel.content
            }
        }
    }
    
    let containerView = UIView()
    
    var openSafariButton = UIButton()
    
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
        authorLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        return authorLabel
    }()
    
    let publishedAtLabel: UILabel = {
        let publishedAtLabel = UILabel()
        publishedAtLabel.text = "4h ago"
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
        return titleLabel
    }()
    
    let sourceLabel: UILabel = {
        let sourceLabel = UILabel()
        sourceLabel.text = "The Washington Post".uppercased()
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

        view.backgroundColor = ColorCompatibility.systemBackground
        
        self.navigationItem.title = viewModel?.source.name!.uppercased()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .heavy)]
        self.navigationItem.largeTitleDisplayMode = .never
        
        configureButton()
        
        view.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(openSafariButton.snp.top).offset(-20)
        }
        
        view.addSubview(publishedAtLabel)
        publishedAtLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentLabel.snp.top).offset(-20)
            make.trailing.equalToSuperview().inset(20)
        }
        publishedAtLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        publishedAtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        view.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
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
    
extension DetailsViewController {
      func configureButton() {
          
          if #available(iOS 15.0, *) {
              var config = UIButton.Configuration.filled()
              config.buttonSize = .large
              config.cornerStyle = .large
              config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                  var outgoing = incoming
                  outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
                  return outgoing
              }
              config.title = "Read more on the Web"
              config.image = UIImage(systemName: "safari")
              config.imagePadding = 5
              config.imagePlacement = .trailing
              config.preferredSymbolConfigurationForImage
              = UIImage.SymbolConfiguration(scale: .medium)
              openSafariButton.configuration = config
          } else {
              openSafariButton = UIButton(type: .roundedRect)
              openSafariButton.setTitle(" Read more on the Web", for: .normal)
              
              var buttonImage = UIImage()
              
              if #available(iOS 13.0, *) {
                  let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .medium)
                  buttonImage = UIImage(systemName: "safari", withConfiguration: buttonImageConfig)!
              } else {
                  buttonImage = UIImage(named: "safari")!
              }
              
              openSafariButton.setImage(buttonImage, for: .normal)
              
              openSafariButton.backgroundColor = .systemBlue
              openSafariButton.tintColor = .white
              openSafariButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
              openSafariButton.layer.cornerRadius = 17
              
              if #available(iOS 13.0, *) {
                  openSafariButton.layer.cornerCurve = .continuous
              }
              
          }
          
          if #available(iOS 14.0, *) {
              openSafariButton.addAction(
                UIAction {_ in
                    self.handleButtonPress()
                }, for: .touchUpInside)
          } else {
              openSafariButton.addAction(for: .touchUpInside) { [unowned self] in
                  self.handleButtonPress()
              }
          }
        
          view.addSubview(openSafariButton)
          openSafariButton.snp.makeConstraints { make in
              make.leading.trailing.equalToSuperview().inset(40)
              make.height.equalTo(60)
              make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
          }
      }
    
    func handleButtonPress() {
        guard let link = URL(string: self.viewModel!.url) else {
            print("Invalid link")
            return
        }
        let safariViewController = SFSafariViewController(url: link)
        self.present(safariViewController, animated: true, completion: nil)
    }
}
