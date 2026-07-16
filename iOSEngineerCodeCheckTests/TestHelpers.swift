//
//  TestHelpers.swift
//  iOSEngineerCodeCheckTests
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import Foundation
@testable import iOSEngineerCodeCheck

/// 指定した結果を返すだけのモック API クライアント
struct MockGitHubAPIClient: GitHubAPIClientProtocol {

    var result: Result<RepositorySearchResponse, Error>

    func searchRepositories(keyword: String) async throws -> RepositorySearchResponse {
        try result.get()
    }
}

extension RepositorySearchResponse {

    /// テスト用のレスポンスを生成する。totalCount 省略時は items の件数を使う
    static func stub(items: [Repository], totalCount: Int? = nil) -> RepositorySearchResponse {
        RepositorySearchResponse(totalCount: totalCount ?? items.count, items: items)
    }
}

extension Repository {

    /// テスト用のダミーデータを生成する
    static func stub(
        fullName: String = "yumemi/ios-engineer-codecheck",
        language: String? = "Swift",
        stargazersCount: Int = 10,
        watchersCount: Int = 20,
        forksCount: Int = 30,
        openIssuesCount: Int = 40,
        htmlURL: URL? = URL(string: "https://github.com/yumemi/ios-engineer-codecheck"),
        avatarURL: URL? = URL(string: "https://example.com/avatar.png")
    ) -> Repository {
        Repository(
            fullName: fullName,
            language: language,
            stargazersCount: stargazersCount,
            watchersCount: watchersCount,
            forksCount: forksCount,
            openIssuesCount: openIssuesCount,
            htmlUrl: htmlURL,
            owner: Owner(avatarUrl: avatarURL)
        )
    }
}
