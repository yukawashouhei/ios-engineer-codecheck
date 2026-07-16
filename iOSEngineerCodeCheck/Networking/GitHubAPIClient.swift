//
//  GitHubAPIClient.swift
//  iOSEngineerCodeCheck
//
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import Foundation

/// GitHub API へのアクセスを抽象化するプロトコル。
/// ViewModel はこのプロトコルにのみ依存するため、テスト時にモックへ差し替えられる。
protocol GitHubAPIClientProtocol {
    func searchRepositories(keyword: String) async throws -> [Repository]
}

/// GitHub API 通信で発生しうるエラー
enum GitHubAPIError: LocalizedError {
    case invalidQuery
    case requestFailed
    case serverError(statusCode: Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "検索キーワードが不正です。"
        case .requestFailed:
            return "通信に失敗しました。ネットワーク接続をご確認ください。"
        case .serverError(let statusCode):
            return "サーバーエラーが発生しました。(HTTP \(statusCode))"
        case .decodingFailed:
            return "検索結果の解析に失敗しました。"
        }
    }
}

/// GitHub API クライアントの実装
final class GitHubAPIClient: GitHubAPIClientProtocol {

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchRepositories(keyword: String) async throws -> [Repository] {
        var components = URLComponents(string: "https://api.github.com/search/repositories")
        components?.queryItems = [URLQueryItem(name: "q", value: keyword)]
        guard let url = components?.url else {
            throw GitHubAPIError.invalidQuery
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw GitHubAPIError.requestFailed
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.requestFailed
        }
        guard httpResponse.statusCode == 200 else {
            throw GitHubAPIError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            return try Self.decoder.decode(RepositorySearchResponse.self, from: data).items
        } catch {
            throw GitHubAPIError.decodingFailed
        }
    }
}
