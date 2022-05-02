//
//  ArticleViewModel.swift
//  dNews
//
//  Created by OemDef | HansaDev on 02.05.2022.
//

import UIKit

struct ArticleViewModel {
    let id: UUID
    let source: Source
    let author: String
    let title: String
    let description: String
    let url: String
    let urlToImage: String
    var image: UIImage
    let publishedAt: String
    let publishedAgo: String
    let content: String
}

extension ArticleViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ArticleViewModel, rhs: ArticleViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
