//
//  RepositorySearchViewModelTests.swift
//  iOSEngineerCodeCheckTests
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import XCTest
@testable import iOSEngineerCodeCheck

@MainActor
final class RepositorySearchViewModelTests: XCTestCase {

    func test_検索成功時_リポジトリ一覧が更新されonUpdateが呼ばれる() async {
        let expected: [Repository] = [.stub(fullName: "apple/swift")]
        let viewModel = RepositorySearchViewModel(
            apiClient: MockGitHubAPIClient(result: .success(.stub(items: expected, totalCount: 1234)))
        )
        let onUpdateCalled = expectation(description: "onUpdate が呼ばれる")
        viewModel.onUpdate = { onUpdateCalled.fulfill() }

        viewModel.search(keyword: "swift")

        await fulfillment(of: [onUpdateCalled], timeout: 1)
        XCTAssertEqual(viewModel.repositories, expected)
        XCTAssertEqual(viewModel.totalCount, 1234)
        XCTAssertTrue(viewModel.hasSearched)
    }

    func test_検索失敗時_onErrorでエラーメッセージが通知される() async {
        let viewModel = RepositorySearchViewModel(
            apiClient: MockGitHubAPIClient(result: .failure(GitHubAPIError.requestFailed))
        )
        let onErrorCalled = expectation(description: "onError が呼ばれる")
        var receivedMessage: String?
        viewModel.onError = { message in
            receivedMessage = message
            onErrorCalled.fulfill()
        }

        viewModel.search(keyword: "swift")

        await fulfillment(of: [onErrorCalled], timeout: 1)
        XCTAssertEqual(receivedMessage, GitHubAPIError.requestFailed.localizedDescription)
        XCTAssertTrue(viewModel.repositories.isEmpty)
    }

    func test_空白のみのキーワードでは検索しない() async {
        let viewModel = RepositorySearchViewModel(
            apiClient: MockGitHubAPIClient(result: .success(.stub(items: [.stub()])))
        )
        let onUpdateNotCalled = expectation(description: "onUpdate は呼ばれない")
        onUpdateNotCalled.isInverted = true
        viewModel.onUpdate = { onUpdateNotCalled.fulfill() }

        viewModel.search(keyword: "   ")

        await fulfillment(of: [onUpdateNotCalled], timeout: 0.5)
        XCTAssertTrue(viewModel.repositories.isEmpty)
    }
}
