## ファイル編集ルール

- `github-copilot-workshop/index.html` (バージョンセレクター) は編集しないでください
- `github-copilot-workshop/versions/*/index.html` (各バージョンのコンテンツ) も直接編集しないでください
- コンテンツを更新する場合は、必ず `workshop.md` を編集してください

## workshop.mdの更新手順

1. `workshop.md` を編集
2. 以下のコマンドで最新バージョンを更新:

```bash
make export
```

別バージョンを指定する場合:

```bash
make export VERSION=v1.0.4
```

3. 新しいバージョンをリリースする場合:
   - 新しいバージョンフォルダを作成（例: `versions/v1.0.2/`）
   - `versions.json` を更新して新バージョンを追加
   - `defaultVersion` を新バージョンに変更

## カスタムバージョン（個社向け）の更新手順

カスタムバージョンは `versions.json` に登録せず、`github-copilot-workshop/custom/` 配下に配置します。
バージョンセレクターには表示されず、直接URLでのみアクセスできます。

### 既存のカスタムバージョン

| 名前 | ソースファイル | URL |
|------|---------------|-----|
| NRI | `workshop-nri.md` | `custom/nri/index.html` |
| DENSO | `workshop-denso.md` | `custom/denso/index.html` |

### カスタムバージョンの更新手順

1. 対応するソースファイル（例: `workshop-nri.md`）を編集
2. 以下のコマンドで更新:

```bash
make export-custom NAME=nri
```

### 新しいカスタムバージョンの作成

1. `workshop.md` をコピーして `workshop-<name>.md` を作成
2. タイトルやコンテンツをカスタマイズ
3. `github-copilot-workshop/custom/<name>/` ディレクトリを作成
4. `make export-custom NAME=<name>` を実行
5. この表に新しいカスタムバージョンを追記