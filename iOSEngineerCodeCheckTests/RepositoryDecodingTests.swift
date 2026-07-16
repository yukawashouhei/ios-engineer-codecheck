//
//  RepositoryDecodingTests.swift
//  iOSEngineerCodeCheckTests
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import XCTest
@testable import iOSEngineerCodeCheck

final class RepositoryDecodingTests: XCTestCase {

    func test_GitHubAPIのレスポンスJSONをデコードできる() throws {
        let json = """
        {
            "items": [
                {
                    "full_name": "apple/swift",
                    "language": "C++",
                    "stargazers_count": 60000,
                    "watchers_count": 60000,
                    "forks_count": 9000,
                    "open_issues_count": 500,
                    "owner": {
                        "avatar_url": "https://avatars.githubusercontent.com/u/10639145"
                    }
                }
            ]
        }
        """

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(RepositorySearchResponse.self, from: Data(json.utf8))

        let repository = try XCTUnwrap(response.items.first)
        XCTAssertEqual(repository.fullName, "apple/swift")
        XCTAssertEqual(repository.language, "C++")
        XCTAssertEqual(repository.stargazersCount, 60000)
        XCTAssertEqual(repository.watchersCount, 60000)
        XCTAssertEqual(repository.forksCount, 9000)
        XCTAssertEqual(repository.openIssuesCount, 500)
        XCTAssertEqual(
            repository.owner.avatarUrl,
            URL(string: "https://avatars.githubusercontent.com/u/10639145")
        )
    }

    func test_languageがnullでもデコードできる() throws {
        let json = """
        {
            "items": [
                {
                    "full_name": "user/repo",
                    "language": null,
                    "stargazers_count": 0,
                    "watchers_count": 0,
                    "forks_count": 0,
                    "open_issues_count": 0,
                    "owner": { "avatar_url": "https://example.com/a.png" }
                }
            ]
        }
        """

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(RepositorySearchResponse.self, from: Data(json.utf8))

        XCTAssertNil(response.items.first?.language)
    }
}
