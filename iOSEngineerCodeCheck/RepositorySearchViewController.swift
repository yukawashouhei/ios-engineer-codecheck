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

    private var repositories: [[String: Any]] = []
    private var searchTask: URLSessionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "GitHubのリポジトリを検索"
        searchBar.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Detail",
              let detailViewController = segue.destination as? RepositoryDetailViewController,
              let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        detailViewController.repository = repositories[selectedIndexPath.row]
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Repository", for: indexPath)
        let repository = repositories[indexPath.row]
        cell.textLabel?.text = repository["full_name"] as? String
        cell.detailTextLabel?.text = repository["language"] as? String
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Detail", sender: self)
    }
}

// MARK: - UISearchBarDelegate

extension RepositorySearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTask?.cancel()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }

        let urlString = "https://api.github.com/search/repositories?q=\(keyword)"
        guard let url = URL(string: urlString) else { return }

        searchTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["items"] as? [[String: Any]] else {
                return
            }
            DispatchQueue.main.async {
                self.repositories = items
                self.tableView.reloadData()
            }
        }
        searchTask?.resume()
    }
}
