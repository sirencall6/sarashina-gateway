# Continue 拡張機能 設定ガイド (`config.json`)

本書は、VSCode の AI コーディング支援拡張機能「**Continue**」から、本中継プロキシ（`sarashina-gateway`）経由で Sarashina モデルを利用するための `config.json` の設定手順および設定例です。

---

## 1. 設定ファイルの配置場所

Continue の設定ファイル（`config.json`）は、OS ごとに以下のパスに配置されています。

| OS | パス |
| :--- | :--- |
| **Windows** | `%USERPROFILE%\.continue\config.json`<br>（例: `C:\Users\<ユーザー名>\.continue\config.json`） |
| **macOS / Linux** | `~/.continue/config.json` |

> [!TIP]
> VSCode 上で Continue サイドバー下部の「⚙（歯車アイコン）」をクリックすることでも直接開くことができます。
> また、Continue の `config.json` は **JSONC（コメント付き JSON）** 形式に対応しているため、`//` 形式のコメントをそのまま記述できます。

---

## 2. 設定例 (`config.json`)

以下の内容をコピーし、お使いの `~/.continue/config.json` に設定（または既存の `models` / `embeddingsProvider` 部分を更新）してください。

```jsonc
{
    // ==========================================
    // 1. チャット・コード生成用のモデル設定
    // ==========================================
    // 複数のAIモデルを登録し、VSCodeのチャットUI上で用途に応じて切り替えて利用できます。
    "models": [
        {
            // モデルの表示名（UIのドロップダウン上で選択する際の名称）
            "title": "Sarashina Mini",

            // APIのプロバイダー種別（OpenAI互換APIのため "openai" を指定）
            "provider": "openai",

            // 呼び出すモデルの識別子（Sarashina API 側のモデル名）
            "model": "sarashina3-mini",

            // 中継プロキシサーバーのエンドポイントURL
            // - 本リポジトリのプロキシ（http://127.0.0.1:8000/v1）を指定します
            "apiBase": "http://127.0.0.1:8000/v1",

            // 認証用のAPIキー
            // - プロキシ経由で認証を行う場合はダミー値（"xxxx" 等）でも動作しますが、
            //   プロキシがそのまま Sarashina API に転送する場合は正規の API キーを指定してください。
            "apiKey": "ｘｘｘｘ",

            // 補完・生成時の詳細オプション
            "completionOptions": {
                // ストリーミングレスポンス（逐次出力）の有効/無効
                // - 選択可能な値: true, false
                // - 注意: Sarashina プロキシで一括レスポンスを中継する場合は必ず false を指定します。
                "stream": false
            }
        },
        {
            // 軽量・高速な Nano モデルの設定（簡単なコード補完や軽量タスク向け）
            "title": "Sarashina Nano",
            "provider": "openai",
            "model": "sarashina3-nano",
            "apiBase": "http://127.0.0.1:8000/v1",
            "apiKey": "ｘｘｘｘ",
            "completionOptions": {
                // ストリーミング無効（一括出力）
                "stream": false
            }
        },
        {
            // ガードレール・安全性検証用の Guard モデルの設定
            "title": "Sarashina Guard",
            "provider": "openai",
            "model": "sarashina3-guard",
            "apiBase": "http://127.0.0.1:8000/v1",
            "apiKey": "ｘｘｘｘ",
            "completionOptions": {
                // ストリーミング無効（一括出力）
                "stream": false
            }
        }
    ],

    // ==========================================
    // 2. 埋め込み（@codebase 検索用）モデル設定
    // ==========================================
    // コードベース全体をベクトル化して検索・参照するための埋め込みモデル（1つだけ登録可能）
    "embeddingsProvider": {
        // APIのプロバイダー種別
        "provider": "openai",

        // 埋め込みに使用するモデル名
        "model": "sarashina3-mini",

        // APIのエンドポイントURL（中継プロキシ）
        "apiBase": "http://127.0.0.1:8000/v1",

        // 認証用のAPIキー
        "apiKey": "ｘｘｘｘ",

        // 補完・生成時のオプション
        "completionOptions": {
            // ストリーミングの有効/無効
            // - 選択可能な値: true, false
            // - 規定値: true
            "stream": false
        }
    }
}
```

---

## 3. 設定項目の詳細解説

### (1) `models`（チャット・編集モデルリスト）
Continue のチャット画面およびインラインコード生成（`Ctrl + I`）で使用できるモデルの配列です。
- **`title`**: Continue のチャット下部ドロップダウンに表示される任意の表示名です。
- **`provider`**: `"openai"` を指定することで、OpenAI 仕様の `/v1/chat/completions` 形式で中継プロキシに通信します。
- **`model`**: 実際に呼び出されるモデル名です（例: `sarashina3-mini`, `sarashina3-nano`, `sarashina3-guard`）。
- **`apiBase`**: ローカルで立ち上げた中継プロキシの URL（`http://127.0.0.1:8000/v1`）を指定します。
- **`completionOptions.stream`**: **`false`** に設定します。中継プロキシを介した一括受信を安定して行うための推奨設定です。

### (2) `embeddingsProvider`（コードベース埋め込み検索）
Continue の `@codebase` 機能（プロジェクト内の関連コードをベクトル検索してコンテキストに含める機能）で使用される設定です。
- `@codebase` を実行した際、裏でコードのチャンクをベクトル化するために呼び出されます。
- 中継プロキシおよび Sarashina API 側が埋め込みエンドポイント（`/v1/embeddings`）に対応している必要があります。

---

## 4. 動作確認

1. プロキシサーバーを起動します（`start_proxy.bat` または `.\start_proxy.ps1`）。
2. VSCode で `Ctrl + Shift + P` を押し、`Continue: Focus on Continue Input` またはサイドバーの Continue アイコンを開きます。
3. モデル選択メニューから **「Sarashina Mini」** などを選択します。
4. テストプロンプト（例: `こんにちは`）を送信し、正常に応答が返ってくることを確認します。

---

## 関連ドキュメント

- [Continue 拡張機能 導入・利用ガイド (docs/continue_setup_guide.md)](continue_setup_guide.md)
- [起動・運用手順書 (docs/operation_guide.md)](operation_guide.md)
- [メイン README (README.md)](../README.md)
