# Sarashina Gateway - Server

本ディレクトリには、ローカル中継プロキシサーバーのコアロジック（FastAPI 実装）が配置されています。

## ファイル構成

- **[`sarashina_proxy.py`](sarashina_proxy.py)**: FastAPI を用いた中継プロキシサーバー本体。クライアントからのリクエストを受け取り、ヘッダーおよびボディパラメータを調整して Sarashina API へフォワードします。

## 詳細ドキュメント

サーバーの起動方法、運用手順、VSCode（Continue）との接続設定、トラブルシューティングについては、以下のドキュメントを参照してください。

- [Sarashina プロキシサーバー 起動・運用手順書](../docs/operation_guide.md)
