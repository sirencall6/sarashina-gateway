# Continue 拡張機能 導入・利用ガイド

本書は、VSCode（Visual Studio Code）に AI コーディング支援拡張機能「**Continue**」を導入し、本リポジトリの中継プロキシ（`sarashina-gateway`）経由で Sarashina モデルを利用可能にするまでの手順書です。

---

## 1. 概要

[Continue](https://continue.dev/) は、VSCode や JetBrains などの IDE 上で動作するオープンソースの AI コーディングアシスタントです。
ローカルプロキシサーバー（`sarashina-gateway`）と連携させることで、以下のような機能を VSCode 内で利用できます。

- **AI チャット（`Ctrl + L`）**: コードの解説、バグの特定、実装相談など
- **インラインコード編集（`Ctrl + I`）**: 選択したコードのリファクタリング、機能追加、テスト生成など
- **コンテキスト参照（`@` メンション）**: `@codebase` や `@Files` を用いたプロジェクト全体の検索・参照

---

## 2. 前提条件

- **Visual Studio Code**: バージョン 1.80 以上
- **sarashina-gateway**: プロキシサーバーが起動可能であること（詳細は [起動・運用手順書](operation_guide.md) を参照）

---

## 3. インストール手順

用途に合わせて以下のいずれかの方法でインストールしてください。

### 方法 A: VSCode 拡張機能ビューからインストール（推奨）

1. VSCode を起動します。
2. 左側のアクティビティバーにある **「拡張機能」アイコン**（ショートカット: `Ctrl + Shift + X`）をクリックします。
3. 検索バーに **`Continue`** と入力します。
4. 発行元が **`Continue`** の拡張機能（`Continue - Codestral, Claude, and more`）が表示されたら、**「インストール」** ボタンをクリックします。

### 方法 B: ターミナル（コマンドライン）からインストール

コマンドプロンプトや PowerShell から以下のコマンドを実行してインストールすることも可能です。

```powershell
code --install-extension Continue.continue
```

---

## 4. 初期設定手順

### ステップ 1: 設定ファイル（`config.json`）を開く

1. VSCode の左端（または右端）のアクティビティバーに表示される **Continue アイコン**（またはショートカット `Ctrl + Shift + P` で `Continue: Focus on Continue Input`）をクリックします。
2. Continue パネルの下部にある **歯車アイコン（⚙）** をクリックします。
3. 自動的に `~/.continue/config.json` がエディタ上で開きます。

> [!NOTE]
> 設定ファイルの実際の保存場所:
> - **Windows**: `C:\Users\<ユーザー名>\.continue\config.json`
> - **macOS / Linux**: `~/.continue/config.json`

### ステップ 2: Sarashina プロキシの設定を反映する

開いた `config.json` に、ローカルプロキシ経由で Sarashina モデル（Mini, Nano, Guard）を利用するための設定を記述します。

具体的な設定内容や各パラメータの詳細については、以下の設定ガイドを参照してください。
- **[Continue 拡張機能 設定ガイド (`config.json`)](continue_config.md)**

設定ファイルを保存（`Ctrl + S`）すると、VSCode の再起動なしで即座に反映されます。

---

## 5. 基本的な使い方

### 1. モデルの選択
Continue パネル下部のモデル選択ドロップダウンをクリックし、設定した **「Sarashina Mini」** や **「Sarashina Nano」** などを選択します。

### 2. チャット機能（`Ctrl + L`）
1. 質問したいコードがある場合は、エディタ上でコードを選択した状態で **`Ctrl + L`**（macOS は `Cmd + L`）を押します。
2. Continue パネルに選択範囲のコードが添付されます。
3. プロンプト（例: `この関数の役割を教えてください`）を入力して Enter を押すと、回答が生成されます。

### 3. インライン編集（`Ctrl + I`）
1. 修正・リファクタリングしたいコードをエディタ上で選択し、**`Ctrl + I`**（macOS は `Cmd + I`）を押します。
2. エディタ内にプロンプト入力バーが表示されます。
3. 指示（例: `型アノテーションを追加して`、`エラーハンドリングを追加して`）を入力して Enter を押します。
4. 生成された差分（Diff）を確認し、よければ **「Accept」**（`Ctrl + Shift + Enter`）を押して適用します。

### 4. コンテキスト参照（`@` メンション）
プロンプト入力中に `@` を入力することで、プロジェクトの文脈をプロンプトに含めることができます。
- **`@codebase`**: プロジェクト全体の関連コードをベクトル検索して参照します。
- **`@Files`**: 特定のファイル全体を参照に含めます。
- **`@Docs`**: 外部ドキュメントを参照に含めます。

---

## 6. トラブルシューティング

| 症状 | 原因 | 対処方法 |
| :--- | :--- | :--- |
| **`Connection error` / `Failed to fetch`** | 中継プロキシサーバー（`sarashina-gateway`）が起動していない | プロジェクトルートの `start_proxy.bat` または `.\start_proxy.ps1` を実行してプロキシを起動してください。 |
| **モデル選択肢に Sarashina が表示されない** | `config.json` の記述構文（カンマ抜け、括弧の不整合など）に誤りがある | `config.json` に文法エラーの赤波線が出ていないか確認してください。 |
| **応答が途中で切れる / エラーが出る** | `stream: true` になっている | `config.json` の各モデル設定で `"stream": false` が指定されているか確認してください。 |

---

## 7. 関連ドキュメント

- [Continue 設定ガイド (`config.json`)](continue_config.md)
- [Sarashina プロキシサーバー 起動・運用手順書](operation_guide.md)
- [メイン README](../README.md)
