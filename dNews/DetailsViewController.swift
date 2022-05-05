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
                    guard URL(string: viewModel.urlToImage) != nil else { return }
                    imageView.af.setImage(withURL: URL(string: viewModel.urlToImage)!, placeholderImage: UIImage(named: "placeholder"))
                }
                publishedAtLabel.text = viewModel.publishedAgo
                contentLabel.text = viewModel.content
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
                configureButton()
                reconstraint()
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
        publishedAtLabel.textAlignment = .natural
        publishedAtLabel.translatesAutoresizingMaskIntoConstraints = false
        return publishedAtLabel
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "The threat of nuclear war is real, top Russian official says; U.S. wants to see Moscow ‘weakened’"// - CNBC"
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
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
        view.addSubview(publishedAtLabel)
        view.addSubview(authorLabel)
        view.addSubview(titleLabel)
        view.addSubview(containerView)
        containerView.addSubview(imageView)
        
        contentLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(openSafariButton.snp.top).offset(-20)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(contentLabel.snp.top).offset(-20)
            //make.bottom.equalToSuperview().inset(20)
        }
        
        publishedAtLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentLabel.snp.top).offset(-20)
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(authorLabel.snp.trailing).offset(14).priority(.high)
        }
        publishedAtLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(authorLabel.snp.top).offset(-14)
        }

        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)//.offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-20)
        }
        
        containerView.layoutIfNeeded()
        
        imageView.frame = containerView.bounds
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func rescaleFont() {
        if fontScaleConst != nil {
            authorLabel.font = UIFont.systemFont(ofSize: 16 * fontScaleConst!, weight: .bold)
            publishedAtLabel.font = UIFont.systemFont(ofSize: 16 * fontScaleConst!, weight: .regular)
            titleLabel.font = UIFont.systemFont(ofSize: 26 * fontScaleConst!, weight: .heavy)
            sourceLabel.font = UIFont.systemFont(ofSize: 14 * fontScaleConst!, weight: .heavy)
            contentLabel.font = UIFont.systemFont(ofSize: 16 * fontScaleConst!, weight: .regular)
        }
    }
    
    func reconstraint() {
        if marginConst != nil {
            openSafariButton.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(marginConst! * 2)
                make.height.equalTo(marginConst! * 3)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(marginConst! * 0.8)
            }
            
            contentLabel.snp.updateConstraints { make in
                make.leading.trailing.equalToSuperview().inset(marginConst!)
                make.bottom.equalTo(openSafariButton.snp.top).offset(-marginConst!)
            }
            contentLabel.setContentCompressionResistancePriority(.required+2, for: .vertical)
            contentLabel.setContentHuggingPriority(.required+1, for: .vertical)

            
            authorLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().inset(marginConst!)
                make.bottom.equalTo(contentLabel.snp.top).offset(-marginConst!)
            }
            authorLabel.setContentCompressionResistancePriority(.required+2, for: .vertical)
            authorLabel.setContentHuggingPriority(.required+1, for: .vertical)

            publishedAtLabel.snp.updateConstraints { make in
                make.bottom.equalTo(contentLabel.snp.top).offset(-marginConst!)
                make.trailing.equalToSuperview().inset(marginConst!)
                make.leading.equalTo(authorLabel.snp.trailing).offset(marginConst! * 0.6).priority(.high)
            }
            publishedAtLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            publishedAtLabel.setContentCompressionResistancePriority(.required+2, for: .vertical)
            publishedAtLabel.setContentHuggingPriority(.required+1, for: .vertical)
        
            titleLabel.snp.updateConstraints { make in
                make.leading.trailing.equalToSuperview().inset(marginConst!)
                make.bottom.equalTo(authorLabel.snp.top).offset(-marginConst! * 0.3)
            }
            titleLabel.setContentCompressionResistancePriority(.required+2, for: .vertical)
            titleLabel.setContentHuggingPriority(.required+1, for: .vertical)


            containerView.snp.updateConstraints { make in
                make.bottom.equalTo(titleLabel.snp.top).offset(-marginConst!)
            }
            //containerView.setContentHuggingPriority(.required+1, for: .vertical)

            
            containerView.layoutIfNeeded()
            
            imageView.frame = containerView.bounds
            imageView.snp.updateConstraints { make in
                make.edges.equalToSuperview()
            }
        }
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
