//
//  RepositoryDetailViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

/// 選択されたリポジトリの詳細を表示する画面
final class RepositoryDetailViewController: UIViewController {

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var starsLabel: UILabel!
    @IBOutlet private weak var watchersLabel: UILabel!
    @IBOutlet private weak var forksLabel: UILabel!
    @IBOutlet private weak var issuesLabel: UILabel!

    /// 遷移元から渡される ViewModel
    var viewModel: RepositoryDetailViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel else { return }
        configure(with: viewModel)
    }

    private func configure(with viewModel: RepositoryDetailViewModel) {
        titleLabel.text = viewModel.titleText
        languageLabel.text = viewModel.languageText
        starsLabel.text = viewModel.starsText
        watchersLabel.text = viewModel.watchersText
        forksLabel.text = viewModel.forksText
        issuesLabel.text = viewModel.issuesText
        loadAvatarImage(from: viewModel.avatarURL)
    }

    private func loadAvatarImage(from url: URL?) {
        guard let url else { return }
        Task { [weak self] in
            let image = await ImageLoader.load(from: url)
            self?.avatarImageView.image = image
        }
    }
}
