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
    
    private var nextPageToLoad = 1
    private var currentlyLoading = false
    private var initialLoad = true
    private var collectionViewIsLoaded = false
    
    var collectionView: UICollectionView!
    
    var dataSource: CollectionViewDiffableDataSource<DSection, ArticleViewModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ColorCompatibility.systemBackground
        
        getArticles()
        
        self.navigationController?.navigationBar.topItem?.title = "dNews"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isNavigationBarHidden = false
        //self.navigationController?.modalPresentationCapturesStatusBarAppearance = true
        
        if #available(iOS 13, *) { } else {
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
        
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
        
        //collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
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
            layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(28))
        }
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        layoutSectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        /*if #available(iOS 14.0, *) {
            layoutSectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        } else {
            layoutSectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        }*/
        
        return layoutSectionHeader
    }
    
    func createTopHeadlinesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func createExploreSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.37))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
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
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCollectionViewCell.reuseId, for: indexPath) as! ExploreCollectionViewCell
                cell.viewModel = viewModel
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { return nil }
            guard let firstArticle = self.dataSource?.itemIdentifier(for: indexPath) else { return nil }
            guard let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: firstArticle) else { return nil }
            if section.title.isEmpty { return nil }
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

/*class ViewController: UIViewController {
    
    var newArticles = [Article]()
    var viewModels = [ArticleViewModel]()
    var sections = [DSection]()
    
    private var nextPageToLoad = 1
    private var currentlyLoading = false
    private var initialLoad = true
    private var collectionViewIsLoaded = false
    
    var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<DSection, ArticleViewModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ColorCompatibility.systemBackground
        self.navigationController?.navigationBar.topItem?.title = "dNews"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.modalPresentationCapturesStatusBarAppearance = true
        
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
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        if #available(iOS 14.0, *) {
            layoutSectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        } else {
            layoutSectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        }
        
        return layoutSectionHeader
    }
    
    func createTopHeadlinesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func createExploreSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.37))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
                
        let header = createSectionHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<DSection, ArticleViewModel>(collectionView: collectionView, cellProvider: { collectionView, indexPath, viewModel in
            switch self.sections[indexPath.section].type {
            case "topHeadlinesSection":
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCollectionViewCell.reuseId, for: indexPath) as! TrendingCollectionViewCell
                cell.viewModel = viewModel
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCollectionViewCell.reuseId, for: indexPath) as! ExploreCollectionViewCell
                cell.viewModel = viewModel
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { return nil }
            guard let firstArticle = self.dataSource?.itemIdentifier(for: indexPath) else { return nil }
            guard let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: firstArticle) else { return nil }
            if section.title.isEmpty { return nil }
            sectionHeader.title.text = section.title
            return sectionHeader
        }
    }
    
    func reloadData() {
        collectionViewIsLoaded = false
        var snapshot = NSDiffableDataSourceSnapshot<DSection, ArticleViewModel>()
        
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        
        dataSource?.apply(snapshot)
        collectionViewIsLoaded = true
    }
    
}*/

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let selectedItem = dataSource?.itemIdentifier(for: indexPath) else { return }
        let detailsVC = DetailsViewController()
        detailsVC.viewModel = selectedItem
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
                
                guard let topHeadlines = response.value else { return }
                
                self.nextPageToLoad += 1
                self.newArticles = topHeadlines.articles
                
                self.separateDataIntoSections()
                
                if self.initialLoad {
                    self.setupCollectionView()
                    self.createDataSource()
                }
                
                self.reloadData()
                
                if self.initialLoad {
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.view.safeAreaInsets.top), animated: false)
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
