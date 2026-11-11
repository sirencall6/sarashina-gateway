<#
.SYNOPSIS
    Sarashina 中継プロキシサーバー (server/sarashina_proxy.py) 起動スクリプト
.DESCRIPTION
    - 仮想環境 (.venv) の自動検出
    - 依存パッケージ (fastapi, uvicorn, httpx) の確認・自動案内
    - ポート 8000 の重複（二重起動）チェック
    - UTF-8 エンコーディング設定
    - 終了時の任意キー入力待機（自動終了防止）
#>

[CmdletBinding()]
param()

# 文字コードを UTF-8 に設定（日本語メッセージの文字化け防止）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

try {
    # スクリプト自身のディレクトリを基準にルートパスを設定
    $ProjectRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    if (-not $ProjectRoot) { $ProjectRoot = (Get-Location).Path }
    $ProxyScript = Join-Path $ProjectRoot "server\sarashina_proxy.py"

    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host " Sarashina Proxy 起動ランチャー" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan

    # 1. 対象の Python スクリプト存在チェック
    if (-not (Test-Path $ProxyScript)) {
        Write-Error "エラー: 起動対象のスクリプトが見つかりません: $ProxyScript"
        exit 1
    }

    # 2. Python 実行環境の自動判別（.venv 優先）
    $PythonCmd = $null
    $VenvPython = Join-Path $ProjectRoot ".venv\Scripts\python.exe"

    if (Test-Path $VenvPython) {
        Write-Host "[環境] 仮想環境 (.venv) を検出しました。" -ForegroundColor Green
        $PythonCmd = $VenvPython
    } else {
        $cmdPython = Get-Command python -ErrorAction SilentlyContinue
        if ($cmdPython) {
            $PythonCmd = "python"
        } else {
            $cmdPy = Get-Command py -ErrorAction SilentlyContinue
            if ($cmdPy) {
                $PythonCmd = "py"
            }
        }
    }

    if (-not $PythonCmd) {
        Write-Error "エラー: 有効な Python コマンドが見つかりませんでした。"
        Write-Host "Python をインストールするか、環境変数 PATH の設定を確認してください。" -ForegroundColor Yellow
        exit 1
    }

    # 3. ポート 8000 の使用状況チェック（二重起動防止）
    $Port = 8000
    try {
        $portActive = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
        if ($portActive) {
            $procId = ($portActive | Select-Object -First 1).OwningProcess
            Write-Warning "警告: ポート $Port は既に別のプロセス (PID: $procId) で使用されています。"
            Write-Warning "すでにプロキシが起動しているか、別のサーバーがポートを占有しています。"
            $confirm = Read-Host "それでも起動を試みますか？ (y/N)"
            if ($confirm -ne "y" -and $confirm -ne "Y") {
                Write-Host "起動を中止しました。" -ForegroundColor Yellow
                exit 0
            }
        }
    } catch {
        # CIM/WMIへのアクセス権限がない環境ではチェックをスキップ
    }

    # 4. 依存パッケージの確認
    Write-Host "[確認] 依存ライブラリ (fastapi, uvicorn, httpx) を確認中..." -ForegroundColor Gray
    $pkgCheck = & $PythonCmd -c "import fastapi, uvicorn, httpx" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "必要なライブラリが不足している場合があります。"
        $installChoice = Read-Host "不足ライブラリを今すぐインストールしますか？ (Y/n)"
        if ($installChoice -eq "" -or $installChoice -eq "y" -or $installChoice -eq "Y") {
            Write-Host "[導入] pip install fastapi uvicorn httpx を実行します..." -ForegroundColor Cyan
            & $PythonCmd -m pip install fastapi uvicorn httpx
            if ($LASTEXITCODE -ne 0) {
                Write-Error "ライブラリのインストールに失敗しました。"
                exit 1
            }
        } else {
            Write-Warning "ライブラリのインストールをスキップしました（起動時にエラーが発生することがあります）。"
        }
    }

    # 5. プロキシサーバー起動
    Write-Host ""
    Write-Host "--------------------------------------------------" -ForegroundColor Green
    Write-Host " サーバーを起動します..." -ForegroundColor Green
    Write-Host " 終了するには [Ctrl + C] を押してください。" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------" -ForegroundColor Green
    Write-Host ""

    & $PythonCmd $ProxyScript
}
catch {
    Write-Error "予期せぬエラーが発生しました: $_"
    exit 1
}
finally {
    # バッチファイル経由の場合は bat 側の pause に任せ、
    # 直接 PowerShell から起動された場合のみ自動終了防止のため待機
    if (-not $env:LAUNCHED_BY_BAT) {
        Write-Host ""
        Write-Host "続行するには何かキーを押してください . . . " -ForegroundColor Gray -NoNewline
        try {
            while ([Console]::KeyAvailable) {
                $null = [Console]::ReadKey($true)
            }
            [void][Console]::ReadKey($true)
        } catch {
            [void](Read-Host)
        }
        Write-Host ""
    }
}