//
//  URLFactory.swift
//  dNews
//
//  Created by OemDef | HansaDev on 02.05.2022.
//

import Foundation

enum URLFactory {
    private static let apiKey = "3f0aff67287244ca81ac1d8a09393e9b"
    private static var baseUrl: URL {
        return baseUrlComponents.url!
    }
    private static let baseUrlComponents: URLComponents = {
        let url = URL(string: "https://newsapi.org/v2/")!
        let queryItem = URLQueryItem(name: "apiKey", value: URLFactory.apiKey)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [queryItem]
        return urlComponents
    }()

    static func articles(params: ArticlesRequestParams) -> String {
        let params = [URLQueryItem(name: "pageSize", value: "\(params.pageSize)"),
                      URLQueryItem(name: "page", value: "\(params.page)"),
                      URLQueryItem(name: "language", value: params.language)]
        var urlComponents = baseUrlComponents
        urlComponents.queryItems?.append(contentsOf: params)
        return urlComponents.url!.appendingPathComponent("top-headlines").absoluteString
    }
}
