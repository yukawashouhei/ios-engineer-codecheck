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
    var starsText: String { "\(repository.stargazersCount) stars" }
    var watchersText: String { "\(repository.watchersCount) watchers" }
    var forksText: String { "\(repository.forksCount) forks" }
    var issuesText: String { "\(repository.openIssuesCount) open issues" }
    var avatarURL: URL? { repository.owner.avatarUrl }
}
