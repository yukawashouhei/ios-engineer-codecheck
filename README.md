# GitHub リポジトリ検索アプリ（ゆめみ iOS エンジニアコードチェック課題）

GitHub のリポジトリをキーワード検索し、詳細情報（オーナーアイコン・言語・Star / Watcher / Fork / Issue 数）を表示する iOS アプリです。
本リポジトリは [ゆめみ iOS エンジニアコードチェック課題](https://github.com/yumemi-inc/ios-engineer-codecheck) のベースプロジェクトをリファクタリングしたものです。

![動作イメージ](README_Images/app.gif)

## 環境

- Xcode 26.6 / Swift 5.9+
- 開発ターゲット: iOS 17.2
- サードパーティーライブラリー: 不使用（標準フレームワークのみ）

## 実行方法

`iOSEngineerCodeCheck.xcodeproj` を Xcode で開き、`iOSEngineerCodeCheck` スキームを選択してビルド・実行してください。テストは `Cmd + U` で実行できます。

## 取り組んだ課題

| Issue | 難易度 | 内容 |
|--|--|--|
| #4 | 初級 | ソースコードの可読性の向上 |
| #5 | 初級 | ソースコードの安全性の向上 |
| #6 | 初級 | バグを修正 |
| #7 | 初級 | Fat VC の回避 |
| #8 | 中級 | プログラム構造をリファクタリング |
| #9 | 中級 | アーキテクチャを適用（MVVM） |
| #12 | 中級 | テストを追加（UnitTest / UITest） |

コミットは課題 Issue ごとに分けており、各コミットメッセージに対応する Issue 番号を記載しています。

### 主な改善点

**バグ修正**
- `wachers_count` というキー名のタイポにより Watcher 数が常に 0 と表示されていた問題を修正
- 検索キーワードが URL エンコードされておらず、日本語やスペースを含む検索でクラッシュする問題を `URLComponents` で修正
- 詳細画面の StackView に縦位置の制約がなくレイアウトが曖昧だった問題を修正
- 通信クロージャが `self` を強参照していた問題を `[weak self]` で修正

**安全性・可読性**
- 強制アンラップ（`!` / `try!` / `as!`）と不必要な IUO を全廃し、`guard let` によるアンラップに統一
- `SchBr`, `TtlLbl` のような省略命名を [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) に沿った名前に変更
- JSON を `[String: Any]` のまま引き回すのをやめ、`Codable` な `Repository` モデルに置き換え（キー名の打ち間違いをコンパイル時に検出できる）

**アーキテクチャ（MVVM + プロトコルによる通信層の抽象化）**

```
iOSEngineerCodeCheck/
├── Models/        # Repository（Codable モデル）
├── Networking/    # GitHubAPIClient（通信層）, ImageLoader
├── ViewModels/    # 画面の状態とロジック
└── Views/         # ViewController（表示のみ）
```

- **View**（ViewController）は「ViewModel の状態を画面に映す」ことに専念
- **ViewModel** が検索の実行・結果の保持・エラーハンドリングを担当。`onUpdate` / `onError` クロージャで View に変更を通知
- **通信層**は `GitHubAPIClientProtocol` として抽象化し、ViewModel はプロトコルにのみ依存（Repository パターン相当）。テスト時はモックに差し替え可能
- 通信は `async/await` を使用し、HTTP ステータスやデコード失敗を `GitHubAPIError` として分類してユーザーにアラートで提示
- 連続検索時は実行中のタスクをキャンセルしてから新しい検索を開始

**テスト**
- ViewModel の単体テスト（検索成功・失敗・空キーワード）— モック API クライアントを注入しネットワーク非依存で検証
- API レスポンス JSON のデコードテスト（`language: null` の場合を含む）
- 「検索 → 一覧 → 詳細画面遷移」の一連のフローを検証する UITest

## AI サービスの利用について

本課題では AI コーディングエージェント（Claude Code）を利用しています。

- 課題 Issue を 1 つずつ確認し、「Issue 単位でコミットを分ける」「各修正の意図をコミットメッセージに明記する」「毎コミットでビルド・テストを通す」という進め方を指示して作業しました
- アーキテクチャの選定（MVVM / MVP の比較検討）やエラーハンドリング方針は、AI に選択肢と根拠を提示させた上で自分で判断しています
- AI が関与したコミットには `Co-Authored-By` を付与し、透明性を確保しています
