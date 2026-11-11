# Sarashina プロキシサーバー 起動・運用手順書

本書は、VSCode 拡張機能（Continue など）から Sarashina AI を利用するためのローカル中継プロキシサーバー（[`server/sarashina_proxy.py`](../server/sarashina_proxy.py)）の起動・停止および運用手順書です。

---

## 1. 概要

本サーバーは、クライアント（Continue 等）と Sarashina API の間に立ち、以下の処理を行う中継プロキシです。

- **不要パラメータの除去**: Sarashina 側で未対応のパラメータ（`stream_options`, `logprobs` 等）を自動削除。
- **パラメータ名変換**: `max_tokens` を `max_completion_tokens` に変換。
- **コネクションの適正終了**: VSCode 側の接続誤切断（Premature close）を防ぐため、`Connection: close` ヘッダーを制御。
- **受付エンドポイント**: `http://127.0.0.1:8000/v1/chat/completions`

---

## 2. 動作要件・前提条件

- **OS**: Windows 10 / 11
- **Python**: Python 3.9 以上
- **必要ライブラリ**:
  - `fastapi`
  - `uvicorn`
  - `httpx`

※ 起動スクリプト（`start_proxy.ps1`）を実行した場合、ライブラリが不足していれば自動でインストール確認プロンプトが表示されます。

---

## 3. 起動手順

---

## 4. 起動時の表示と状態確認

正常に起動すると、コンソールに以下のように表示されます。

```text
==================================================
 Sarashina 中継サーバー（Connection: close 対策版）起動
 ※ 終了するには [Ctrl + C] を押してください
==================================================
INFO:     Started server process [xxxxx]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

この画面が表示されている間、プロキシがリクエストを待ち受けています。

---

## 5. 停止手順

プロキシサーバーを停止するには、サーバーが動作しているターミナル・ウィンドウで **`Ctrl + C`** を押します。

```text
^C
[Ctrl + C] を検知しました。サーバーを終了しました。
```

上記メッセージが表示され、正常にシャットダウンされます。

---

## 6. VSCode（Continue）との接続設定

VSCode の Continue 拡張機能設定ファイル（`~/.continue/config.json`）にて、以下の通り `apiBase` をローカルサーバーに向けて設定します。

```json
{
  "models": [
    {
      "title": "Sarashina Mini",
      "provider": "openai",
      "model": "sarashina3-mini",
      "apiBase": "http://127.0.0.1:8000/v1",
      "apiKey": "<SarashinaのAPIキー>",
      "completionOptions": {
        "stream": false
      }
    }
  ]
}
```

---

## 7. トラブルシューティング

| 症状                                                         | 原因                                                                     | 対処方法                                                                                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------ |
| **`警告: ポート 8000 は既に別のプロセスで使用されています`** | すでに別のウィンドウでプロキシが起動中、または別のアプリがポートを使用中 | 既存のプロキシウィンドウを閉じるか、タスクマネージャー等で該当プロセス（PID）を終了してください。                         |
| **`エラー: Python が環境変数 PATH に見つかりません`**        | Python が未インストール、または環境変数 PATH に登録されていない          | Python 公式インストーラーから「Add python.exe to PATH」にチェックを入れてインストールしてください。                       |
| **PowerShell スクリプトの実行が禁止されているエラー**        | Windows の ExecutionPolicy の制限                                        | `start_proxy.bat` から起動するか、ターミナルで `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` を実行してください。 |
| **API から 401 Unauthorized が返る**                         | API キーの有効期限切れ、または誤り                                       | Continue の `config.json` に設定されている `apiKey` が正しいか確認してください。                                          |
