# sarashina-gateway

VSCode 拡張機能（Continue 等）から **Sarashina AI** を快適に利用するためのローカル中継プロキシゲートウェイです。

## 概要

クライアントと Sarashina API の間に立ち、互換性のないパラメータの制御やコネクション維持を行い、安定した AI コーディング環境を提供します。

- **パラメータ変換・除去**: Sarashina 側で未対応のパラメータ（`stream_options`, `logprobs` 等）の除去、`max_tokens` の変換など
- **コネクション制御**: VSCode 側の意図しない接続切断を防止
- **ワンクリック起動**: Windows 用バッチファイル（`start_proxy.bat`）および PowerShell スクリプト（`start_proxy.ps1`）を同梱

## ドキュメント

- [起動・運用手順書（docs/operation_guide.md）](docs/operation_guide.md)  
  サーバーの起動方法（バッチ・PowerShell・手動）、停止方法、動作要件、トラブルシューティングをまとめています。
- [Continue 導入・利用ガイド（docs/continue_setup_guide.md）](docs/continue_setup_guide.md)  
  VSCode への Continue 拡張機能のインストール手順、初期設定、基本的な使い方（チャット・インライン編集等）を解説しています。
- [Continue 設定ガイド（docs/continue_config.md）](docs/continue_config.md)  
  VSCode の Continue 拡張機能向け `config.json` の設定例（Mini / Nano / Guard モデル、埋め込み設定など）を解説しています。

## クイックスタート

エクスプローラーから `start_proxy.bat` を実行するか、ターミナルで以下を実行してください。

```powershell
cd d:\work_vsc\sarashina-gateway
.\start_proxy.ps1
```

受付エンドポイント: `http://127.0.0.1:8000/v1/chat/completions`

## ディレクトリ構成

```text
sarashina-gateway/
  ├─ docs/
  │   ├─ operation_guide.md         # 起動・運用手順書
  │   ├─ continue_setup_guide.md    # Continue 拡張機能導入・利用ガイド
  │   └─ continue_config.md         # Continue 拡張機能設定ガイド
  ├─ server/
  │   ├─ README.md                  # サーバー実装に関する説明
  │   └─ sarashina_proxy.py         # プロキシサーバー本体（FastAPI）
  ├─ start_proxy.bat                # Windows 向け起動バッチ
  ├─ start_proxy.ps1                # 起動用 PowerShell スクリプト
  ├─ .gitignore
  ├─ LICENSE
  └─ README.md
```

## ライセンス

[MIT License](LICENSE)
