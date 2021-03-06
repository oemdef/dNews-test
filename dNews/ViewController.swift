//
//  ViewController.swift
//  dNews
//
//  Created by OemDef | HansaDev on 26.04.2022.
//

import UIKit
import SnapKit
import Alamofire
import IBPCollectionViewCompositionalLayout
import DiffableDataSources

class ViewController: UIViewController {
    
    var newArticles = [Article]()
    var viewModels = [ArticleViewModel]()
    var sections = [DSection]()
    
    var marginConst: CGFloat = 0
    var fontScaleConst: CGFloat = 0
    
    private var nextPageToLoad = 1
    private var currentlyLoading = false
    private var initialLoad = true
    private var collectionViewIsLoaded = false
    
    var collectionView: UICollectionView!
    
    var dataSource: CollectionViewDiffableDataSource<DSection, ArticleViewModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorCompatibility.systemBackground
        
        self.navigationController?.navigationBar.topItem?.title = "dNews"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isNavigationBarHidden = false
                
        if #available(iOS 13, *) { } else {
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
        
        marginConst = self.navigationController!.systemMinimumLayoutMargins.leading
        
        let font = UIFont.preferredFont(forTextStyle: .largeTitle)
        fontScaleConst = font.pointSize / 34
        
        getArticles()
    }
    
    func setupCollectionView() {
        print("setupCollectionView")
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = ColorCompatibility.systemBackground
        
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(TrendingCollectionViewCell.self, forCellWithReuseIdentifier: TrendingCollectionViewCell.reuseId)
        collectionView.register(ExploreCollectionViewCell.self, forCellWithReuseIdentifier: ExploreCollectionViewCell.reuseId)
        
        collectionView.delegate = self
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section = self.sections[sectionIndex]
            switch section.type {
            case "topHeadlinesSection":
                return self.createTopHeadlinesSection()
            default:
                return self.createExploreSection()
            }
        }
        
        return layout
    }
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        var layoutSectionHeaderSize: NSCollectionLayoutSize
        if #available(iOS 14.0, *) {
            layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        } else {
            layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(30 * fontScaleConst))
        }
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        layoutSectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: marginConst, bottom: 0, trailing: marginConst)
        
        return layoutSectionHeader
    }
    
    func createTopHeadlinesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: marginConst/2, leading: marginConst, bottom: marginConst/2, trailing: marginConst)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: marginConst, trailing: 0)
        
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func createExploreSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.37))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: marginConst/2, leading: marginConst, bottom: marginConst/2, trailing: marginConst)
        
        var groupSize: NSCollectionLayoutSize
        
        if #available(iOS 14.0, *) {
         groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1))
        } else {
         groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.37))
        }
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
                
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func createDataSource() {
        dataSource = CollectionViewDiffableDataSource<DSection, ArticleViewModel>(collectionView: collectionView, cellProvider: { collectionView, indexPath, viewModel in
            switch self.sections[indexPath.section].type {
            case "topHeadlinesSection":
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCollectionViewCell.reuseId, for: indexPath) as! TrendingCollectionViewCell
                cell.viewModel = viewModel
                cell.marginConst = self.marginConst
                cell.fontScaleConst = self.fontScaleConst
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCollectionViewCell.reuseId, for: indexPath) as! ExploreCollectionViewCell
                cell.viewModel = viewModel
                cell.marginConst = self.marginConst
                cell.fontScaleConst = self.fontScaleConst
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { return nil }
            guard let firstArticle = self.dataSource?.itemIdentifier(for: indexPath) else { return nil }
            guard let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: firstArticle) else { return nil }
            if section.title.isEmpty { return nil }
            sectionHeader.title.font = UIFont.systemFont(ofSize: 28 * self.fontScaleConst, weight: .bold)
            sectionHeader.title.text = section.title
            return sectionHeader
        }
    }
    
    func reloadData() {
        collectionViewIsLoaded = false
        var snapshot = DiffableDataSourceSnapshot<DSection, ArticleViewModel>()
        
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        
        dataSource?.apply(snapshot)
        collectionViewIsLoaded = true
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let selectedItem = dataSource?.itemIdentifier(for: indexPath) else { return }
        let detailsVC = DetailsViewController()
        detailsVC.viewModel = selectedItem
        detailsVC.fontScaleConst = fontScaleConst
        detailsVC.marginConst = marginConst
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !self.currentlyLoading,
              (self.sections[1].items.count - indexPath.row) < 3 else { return }
        print(indexPath.row)
        print(self.sections[1].items.count)
        getArticles()
    }
    
}

private extension ViewController {
    func makeViewModels(_ articles: [Article]) -> [ArticleViewModel] {
        return articles.map { article in
            let id = article.id
            let source = Source(id: article.source.id ?? "No id", name: article.source.name ?? "No name")
            
            var authorLabelText = article.author?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? "\(source.name ?? "No name") Team"
            if authorLabelText.isEmpty {
                authorLabelText = "\(source.name ?? "No name") Team"
            }
            
            let author = authorLabelText
            
            let title = article.title
            let description = article.description ?? "No description"
            let url = article.url ?? "No URL"
            let urlToImage = article.urlToImage ?? "No URL to Image"
            
            let image = UIImage(named: "placeholder")
            
            let publishedAt = article.publishedAt ?? "No date"
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = dateFormatter.date(from: publishedAt)
            
            let publishedAgo = date?.timeAgoDisplay() ?? "? hr ago"
            
            let content = article.content?.components(separatedBy: "[")[0] ?? "No content"
            
            return ArticleViewModel(id: id, source: source, author: author, title: title, description: description, url: url, urlToImage: urlToImage, image: image!, publishedAt: publishedAt, publishedAgo: publishedAgo, content: content)
        }
    }
}

private extension ViewController {
    func getArticles() {
        
        if !shouldLoadMoreData() {
            return
        }
        currentlyLoading = true
        
        let params = ArticlesRequestParams(pageSize: 30, page: self.nextPageToLoad, language: "en")
        let url = URLFactory.articles(params: params)
        
        let request = AF.request(url)
        
        request
            .validate()
            .responseDecodable(of: NewsResponse.self) { (response) in
                
                // MARK: ??? Error handling
                if let afError = response.error?.asAFError {
                    if afError.isSessionTaskError {
                        if self.initialLoad {
                            self.showOfflineAlert(whereFrom: "getArticlesNoInternetOnLaunch")
                            self.currentlyLoading = false
                            return
                        } else {
                            self.showOfflineAlert(whereFrom: "getArticlesNoInternet")
                            self.currentlyLoading = false
                            return
                        }
                    }
                }
                
                if response.value == nil {
                    self.showOfflineAlert(whereFrom: "getArticlesEmpty")
                    self.currentlyLoading = false
                    return
                }
                
                // MARK: ??? Response handling
                guard let topHeadlines = response.value else { return }
                
                self.nextPageToLoad += 1
                self.newArticles = topHeadlines.articles
                
                self.separateDataIntoSections()
                
                if self.initialLoad {
                    self.setupCollectionView()
                    self.createDataSource()
                }
                
                let contentOffsetBeforeLoad = self.collectionView.contentOffset
                
                self.reloadData()
                
                if self.initialLoad {
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.view.safeAreaInsets.top), animated: false)
                }
                
                if #available(iOS 13.0, *) {
                    if !self.initialLoad {
                        self.collectionView.setContentOffset(contentOffsetBeforeLoad, animated: false)
                    }
                }
               
                self.currentlyLoading = false
                self.initialLoad = false
            }
    }
    
    func shouldLoadMoreData() -> Bool {
        if currentlyLoading {
            return false
        }
        return true
    }
    
    func separateDataIntoSections() {
        print("separateDataIntoSections")
        if sections.isEmpty {
            sections.append(DSection(type: "topHeadlinesSection", title: "Top stories"))
            sections.append(DSection(type: "exploreSection", title: "Explore"))
        }
        if sections[0].items.isEmpty {
            let initViewModels = makeViewModels(newArticles)
            for i in 0...9 {
                sections[0].items.append(initViewModels[i])
            }
            for i in 10..<initViewModels.count {
                sections[1].items.append(initViewModels[i])
            }
        } else {
            sections[1].items.append(contentsOf: makeViewModels(newArticles))
        }
    }
}

// MARK: ??? No internet alert

extension ViewController {
    
    func showOfflineAlert(whereFrom: String) {
        switch whereFrom {
        case "getArticlesNoInternetOnLaunch":
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "No connection", message: "There was a problem with your Internet connection", preferredStyle: .alert)
                let actionRetry = UIAlertAction(title: "Try Again", style: .default) { (retry) in
                    self.getArticles()
                }
                alertController.addAction(actionRetry)
                self.present(alertController, animated: true, completion: nil)
            }
        case "getArticlesNoInternet":
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "No connection", message: "There was a problem with your Internet connection", preferredStyle: .alert)
                let actionRetry = UIAlertAction(title: "Try Again", style: .default) { (retry) in
                    self.getArticles()
                }
                let actionCancel = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
                }
                alertController.addAction(actionRetry)
                alertController.addAction(actionCancel)
                self.present(alertController, animated: true, completion: nil)
            }
        case "getArticlesEmpty":
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "No more trending stories", message: "NEWS API returned an empty data array. There is either no more trending stories now, or an API error has occurred.", preferredStyle: .alert)
                let actionOK = UIAlertAction(title: "Got it", style: .default)
                alertController.addAction(actionOK)
                self.present(alertController, animated: true, completion: nil)
            }
        default:
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Something went wrong", message: "Triggered default in switch-case showOfflineAlert", preferredStyle: .alert)
                let actionOK = UIAlertAction(title: "That's interesting", style: .default)
                alertController.addAction(actionOK)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
