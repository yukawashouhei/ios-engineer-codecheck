//
//  RepositorySearchViewModel.swift
//  iOSEngineerCodeCheck
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import Foundation

/// リポジトリ検索画面の状態とロジックを担う ViewModel
@MainActor
final class RepositorySearchViewModel {

    private let apiClient: GitHubAPIClientProtocol
    private var searchTask: Task<Void, Never>?

    /// 検索結果の一覧。更新されると onUpdate が呼ばれる
    private(set) var repositories: [Repository] = []

    /// 検索結果の総件数(表示中の件数とは別に、API が返すヒット総数)
    private(set) var totalCount = 0

    /// 一度でも検索を実行したかどうか(空状態の表示出し分けに使用)
    private(set) var hasSearched = false

    /// 検索結果が更新されたときに呼ばれる
    var onUpdate: (() -> Void)?
    /// エラーが発生したときに、表示用メッセージとともに呼ばれる
    var onError: ((String) -> Void)?

    init(apiClient: GitHubAPIClientProtocol = GitHubAPIClient()) {
        self.apiClient = apiClient
    }

    /// キーワードでリポジトリを検索する。実行中の検索があればキャンセルして置き換える
    func search(keyword: String) {
        let keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return }

        searchTask?.cancel()
        searchTask = Task {
            do {
                let response = try await apiClient.searchRepositories(keyword: keyword)
                try Task.checkCancellation()
                repositories = response.items
                totalCount = response.totalCount
                hasSearched = true
                onUpdate?()
            } catch is CancellationError {
                // 新しい検索に置き換えられた場合は何もしない
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }

    /// 実行中の検索をキャンセルする
    func cancelSearch() {
        searchTask?.cancel()
    }

    /// 指定位置のリポジトリを返す。範囲外の場合は nil
    func repository(at index: Int) -> Repository? {
        repositories.indices.contains(index) ? repositories[index] : nil
    }
}
