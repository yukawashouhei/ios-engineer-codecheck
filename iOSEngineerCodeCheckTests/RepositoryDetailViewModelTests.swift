//
//  RepositoryDetailViewModelTests.swift
//  iOSEngineerCodeCheckTests
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import XCTest
@testable import iOSEngineerCodeCheck

final class RepositoryDetailViewModelTests: XCTestCase {

    func test_表示用テキストが正しく組み立てられる() {
        let viewModel = RepositoryDetailViewModel(
            repository: .stub(
                fullName: "apple/swift",
                language: "C++",
                stargazersCount: 1,
                watchersCount: 2,
                forksCount: 3,
                openIssuesCount: 4
            )
        )

        XCTAssertEqual(viewModel.titleText, "apple/swift")
        XCTAssertEqual(viewModel.languageText, "Written in C++")
        XCTAssertEqual(viewModel.starsText, "1 stars")
        XCTAssertEqual(viewModel.watchersText, "2 watchers")
        XCTAssertEqual(viewModel.forksText, "3 forks")
        XCTAssertEqual(viewModel.issuesText, "4 open issues")
    }

    func test_言語がnilの場合はUnknownと表示する() {
        let viewModel = RepositoryDetailViewModel(repository: .stub(language: nil))

        XCTAssertEqual(viewModel.languageText, "Language: Unknown")
    }
}
