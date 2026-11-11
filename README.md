# sarashina-gateway

VSCode 拡張機能（Continue 等）から **Sarashina AI** を快適に利用するためのローカル中継プロキシゲートウェイです。

## 概要

クライアントと Sarashina API の間に立ち、互換性のないパラメータの制御やコネクション維持を行い、安定した AI コーディング環境を提供します。

- **パラメータ変換・除去**: Sarashina 側で未対応のパラメータ（`stream_options`, `logprobs` 等）の除去、`max_tokens` の変換など
- **コネクション制御**: VSCode 側の意図しない接続切断を防止
- **ワンクリック起動**: Windows 用バッチファイル（`start_proxy.bat`）および PowerShell スクリプト（`start_proxy.ps1`）を同梱

## ドキュメント

- [起動・運用手順書（docs/operation_guide.md）](docs/operation_guide.md)  
  サーバーの起動方法（バッチ・PowerShell・手動）、停止方法、VSCode (Continue) の設定手順、トラブルシューティングをまとめています。

## クイックスタート

エクスプローラーから `start_proxy.bat` を実行するか、ターミナルで以下を実行してください。

```powershell
.\start_proxy.ps1
```

受付エンドポイント: `http://127.0.0.1:8000/v1/chat/completions`

## ディレクトリ構成

```text
sarashina-gateway/
  ├─ docs/
  │   └─ operation_guide.md     # 起動・運用手順書
  ├─ server/
  │   ├─ README.md              # サーバー実装に関する説明
  │   └─ sarashina_proxy.py     # プロキシサーバー本体（FastAPI）
  ├─ start_proxy.bat            # Windows 向け起動バッチ
  ├─ start_proxy.ps1            # 起動用 PowerShell スクリプト
  ├─ .gitignore
  ├─ LICENSE
  └─ README.md
```

## ライセンス

[MIT License](LICENSE)
