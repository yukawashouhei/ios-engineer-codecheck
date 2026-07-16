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

    var result: Result<[Repository], Error>

    func searchRepositories(keyword: String) async throws -> [Repository] {
        try result.get()
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
        avatarURL: URL? = URL(string: "https://example.com/avatar.png")
    ) -> Repository {
        Repository(
            fullName: fullName,
            language: language,
            stargazersCount: stargazersCount,
            watchersCount: watchersCount,
            forksCount: forksCount,
            openIssuesCount: openIssuesCount,
            owner: Owner(avatarUrl: avatarURL)
        )
    }
}
