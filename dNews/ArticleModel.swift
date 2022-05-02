//
//  ArticleModel.swift
//  dNews
//
//  Created by OemDef | HansaDev on 28.04.2022.
//

import Foundation

struct NewsResponse: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let id = UUID()
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

struct Source: Codable, Identifiable {
    let id: String?
    let name: String?
}

struct DSection: Hashable {
    let type: String
    let title: String
    var items: [ArticleViewModel]
    
    init(type: String, title: String) {
        self.type = type
        self.title = title
        self.items = [ArticleViewModel]()
    }
}

struct ArticlesRequestParams {
    let pageSize: Int
    let page: Int
    let language: String
}

extension Article: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.url == rhs.url
    }
    
}

extension Source: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Source, rhs: Source) -> Bool {
        lhs.name == rhs.name
    }
    
}


