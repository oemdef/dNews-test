//
//  ViewController.swift
//  dNews
//
//  Created by OemDef | HansaDev on 26.04.2022.
//

import UIKit
import SnapKit
import Alamofire

class ViewController: UIViewController {
        
    var articles = [Article]()
    var sections = [DSection]()
    
    var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<DSection, Article>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.topItem?.title = "dNews"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.modalPresentationCapturesStatusBarAppearance = true
        
        getArticles()
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        
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
        layoutSectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
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
        dataSource = UICollectionViewDiffableDataSource<DSection, Article>(collectionView: collectionView, cellProvider: { collectionView, indexPath, article in
            switch self.sections[indexPath.section].type {
            case "topHeadlinesSection":
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCollectionViewCell.reuseId, for: indexPath) as! TrendingCollectionViewCell
                cell.article = article
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCollectionViewCell.reuseId, for: indexPath) as! ExploreCollectionViewCell
                cell.article = article
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
        var snapshot = NSDiffableDataSourceSnapshot<DSection, Article>()
        
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        
        dataSource?.apply(snapshot)
    }
    
    func getArticles() {
        let request = AF.request("https://newsapi.org/v2/top-headlines?language=en&pageSize=30&apiKey=b7a09219c47a4ffb9994a8376084fbb3")
        
        request
            .validate()
            .responseDecodable(of: NewsResponse.self) { (response) in
                print(response)
                guard let topHeadlines = response.value else { return }
                print(topHeadlines)
                self.articles = topHeadlines.articles
                
                self.separateDataIntoSections()
                
                self.setupCollectionView()
                self.createDataSource()
                self.reloadData()
            }
    }
    
    func separateDataIntoSections() {
        var lastArticleInArray = articles.count

        if sections.isEmpty {
            sections.append(DSection(type: "topHeadlinesSection", title: "Top stories"))
            sections.append(DSection(type: "exploreSection", title: "Explore"))
        }
        
        if sections[0].items.isEmpty {
            for i in 0...9 {
                sections[0].items.append(articles[i])
            }
            lastArticleInArray = 10
        }
        
        for i in lastArticleInArray..<articles.count {
            sections[1].items.append(articles[i])
        }
        
        lastArticleInArray = articles.count
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let selectedItem = dataSource?.itemIdentifier(for: indexPath) else { return }
        let detailsVC = DetailsViewController()
        detailsVC.article = selectedItem
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
