//
//  RepositorySearchViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

/// GitHub リポジトリを検索し、結果を一覧表示する画面
final class RepositorySearchViewController: UITableViewController {

    @IBOutlet private weak var searchBar: UISearchBar!

    private let viewModel = RepositorySearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "GitHubのリポジトリを検索"
        searchBar.delegate = self
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.updateEmptyState()
            self?.tableView.reloadData()
        }
        viewModel.onError = { [weak self] message in
            self?.presentErrorAlert(message: message)
        }
    }

    /// 検索結果が 0 件のときにメッセージを表示する
    private func updateEmptyState() {
        if viewModel.hasSearched, viewModel.repositories.isEmpty {
            let label = UILabel()
            label.text = "リポジトリが見つかりませんでした"
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Detail",
              let detailViewController = segue.destination as? RepositoryDetailViewController,
              let selectedIndexPath = tableView.indexPathForSelectedRow,
              let repository = viewModel.repository(at: selectedIndexPath.row) else {
            return
        }
        detailViewController.viewModel = RepositoryDetailViewModel(repository: repository)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.repositories.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard viewModel.hasSearched else { return nil }
        let formattedCount = NumberFormatter.localizedString(
            from: NSNumber(value: viewModel.totalCount), number: .decimal
        )
        return "検索結果 \(formattedCount) 件"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Repository", for: indexPath)
        let repository = viewModel.repositories[indexPath.row]
        cell.contentConfiguration = Self.contentConfiguration(for: repository, avatar: nil)

        // アバターは非同期で取得し、セルが再利用されていないことを確認してから反映する
        if let avatarURL = repository.owner.avatarUrl {
            Task {
                guard let avatar = await ImageLoader.load(from: avatarURL),
                      tableView.indexPath(for: cell) == indexPath else { return }
                cell.contentConfiguration = Self.contentConfiguration(for: repository, avatar: avatar)
            }
        }
        return cell
    }

    // MARK: - Cell Content

    private static let languageColors: [String: UIColor] = [
        "Swift": .systemOrange,
        "Objective-C": .systemBlue,
        "Kotlin": .systemPurple,
        "Java": .systemBrown,
        "JavaScript": .systemYellow,
        "TypeScript": .systemTeal,
        "Python": .systemIndigo,
        "Ruby": .systemRed,
        "Go": .systemCyan,
        "C++": .systemPink,
        "Rust": .systemBrown,
    ]

    private static func contentConfiguration(for repository: Repository, avatar: UIImage?) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.subtitleCell()
        content.text = repository.fullName
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.secondaryAttributedText = secondaryText(for: repository)
        content.textToSecondaryTextVerticalPadding = 4
        content.image = avatar ?? UIImage(systemName: "person.crop.circle.fill")
        content.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        content.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        content.imageProperties.cornerRadius = 20
        content.imageProperties.tintColor = .systemGray3
        return content
    }

    /// 「● Swift   ★ 68.2k」のような 2 行目のテキストを組み立てる
    private static func secondaryText(for repository: Repository) -> NSAttributedString {
        let text = NSMutableAttributedString()
        if let language = repository.language {
            text.append(NSAttributedString(
                string: "● ",
                attributes: [.foregroundColor: languageColors[language] ?? UIColor.systemGray]
            ))
            text.append(NSAttributedString(
                string: "\(language)   ",
                attributes: [.foregroundColor: UIColor.secondaryLabel]
            ))
        }
        text.append(NSAttributedString(
            string: "★ \(abbreviatedCount(repository.stargazersCount))",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        ))
        text.addAttribute(
            .font,
            value: UIFont.preferredFont(forTextStyle: .subheadline),
            range: NSRange(location: 0, length: text.length)
        )
        return text
    }

    /// 68200 → "68.2k" のような省略表記に変換する
    private static func abbreviatedCount(_ count: Int) -> String {
        switch count {
        case 1_000_000...:
            return String(format: "%.1fM", Double(count) / 1_000_000)
        case 1_000...:
            return String(format: "%.1fk", Double(count) / 1_000)
        default:
            return "\(count)"
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Detail", sender: self)
    }
}

// MARK: - UISearchBarDelegate

extension RepositorySearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.cancelSearch()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.search(keyword: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
}
