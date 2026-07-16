//
//  Repository.swift
//  iOSEngineerCodeCheck
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import Foundation

/// GitHub リポジトリ 1 件分の情報
struct Repository: Decodable, Equatable {

    /// リポジトリのオーナー情報
    struct Owner: Decodable, Equatable {
        let avatarUrl: URL?
    }

    let fullName: String
    let language: String?
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let owner: Owner
}

/// GitHub Search API (search/repositories) のレスポンス
struct RepositorySearchResponse: Decodable {
    let items: [Repository]
}
