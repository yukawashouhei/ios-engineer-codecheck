//
//  RepositoryDetailViewModel.swift
//  iOSEngineerCodeCheck
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import Foundation

/// リポジトリ詳細画面の表示内容を組み立てる ViewModel
struct RepositoryDetailViewModel {

    private let repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    var titleText: String { repository.fullName }
    var languageText: String {
        repository.language.map { "Written in \($0)" } ?? "Language: Unknown"
    }
    var starsText: String { "\(formatted(repository.stargazersCount)) stars" }
    var watchersText: String { "\(formatted(repository.watchersCount)) watchers" }
    var forksText: String { "\(formatted(repository.forksCount)) forks" }
    var issuesText: String { "\(formatted(repository.openIssuesCount)) open issues" }
    var avatarURL: URL? { repository.owner.avatarUrl }

    /// リポジトリの GitHub ページ URL(「GitHubで見る」ボタン用)
    var repositoryURL: URL? { repository.htmlUrl }

    /// 12345 → "12,345" のような桁区切り表記に変換する
    private func formatted(_ count: Int) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: count), number: .decimal)
    }
}
